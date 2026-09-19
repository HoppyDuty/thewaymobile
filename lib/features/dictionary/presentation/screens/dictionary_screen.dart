import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../shepherd/presentation/widgets/ask_shepherd_sheet.dart';
import '../../data/dictionary_api.dart';
import '../../data/dictionary_local_store.dart';
import '../../data/models/dictionary_entry.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _controller = TextEditingController();
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  Timer? _debounce;

  bool _isLoading = false;
  bool _searched = false;
  List<DictionaryEntry>? _results;
  List<String> _suggestions = [];
  List<String> _didYouMean = [];
  List<String> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    _refreshRecentSearches();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _player.dispose();
    _tts.stop();
    super.dispose();
  }

  void _refreshRecentSearches() {
    setState(() => _recentSearches = ref.read(dictionaryLocalStoreProvider).recentSearches());
  }

  Future<void> _clearRecentSearches() async {
    await ref.read(dictionaryLocalStoreProvider).clearRecentSearches();
    _refreshRecentSearches();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await ref.read(dictionaryApiProvider).suggest(value);
      if (mounted) setState(() => _suggestions = suggestions);
    });
  }

  Future<void> _search([String? word]) async {
    final query = (word ?? _controller.text).trim();
    if (query.isEmpty) return;

    if (word != null) _controller.text = word;
    FocusScope.of(context).unfocus();

    final localStore = ref.read(dictionaryLocalStoreProvider);
    await localStore.recordSearch(query);
    _refreshRecentSearches();

    setState(() {
      _isLoading = true;
      _searched = true;
      _results = null;
      _suggestions = [];
      _didYouMean = [];
    });

    // Offline-first: a word already looked up successfully before never
    // needs the network again (`UI_UX_RULES.md` §11 / product spec §32).
    final cached = localStore.read(query);
    if (cached != null) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) setState(() => _results = cached);
      return;
    }

    try {
      final results = await ref.read(dictionaryApiProvider).lookup(query);
      if (results == null) {
        // Not found — offer spelling-based alternatives.
        final alternatives = await ref.read(dictionaryApiProvider).suggest(query.substring(0, (query.length - 1).clamp(1, query.length)));
        if (mounted) setState(() => _didYouMean = alternatives.take(5).toList());
      } else {
        await localStore.write(query, results);
      }
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Plays the provider's real pronunciation audio when available; falls
  /// back to on-device text-to-speech otherwise (or if playback itself
  /// fails) so the pronounce button is never a silent no-op — previously it
  /// simply wasn't shown at all for a word with no audioUrl.
  Future<void> _pronounce(DictionaryEntry entry) async {
    if (entry.audioUrl != null) {
      try {
        await _player.play(UrlSource(entry.audioUrl!.startsWith('http') ? entry.audioUrl! : 'https:${entry.audioUrl}'));
        return;
      } catch (_) {
        // Fall through to TTS below.
      }
    }

    try {
      await _tts.setLanguage('en-US');
      await _tts.speak(entry.word);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't play pronunciation.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Look up a word',
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onFieldSubmitted: (_) => _search(),
              suffixIcon: IconButton(
                icon: const Icon(AppIcons.search),
                tooltip: 'Search',
                onPressed: () => _search(),
              ),
            ),
            if (_suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final s in _suggestions)
                      ActionChip(label: Text(s), onPressed: () => _search(s)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (_isLoading)
              Expanded(
                child: AppShimmer(
                  child: ListView(
                    children: const [
                      ShimmerBox(height: 28, width: 140),
                      SizedBox(height: AppSpacing.sm),
                      ShimmerBox(height: 16),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(height: 16),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(height: 16, width: 220),
                    ],
                  ),
                ),
              )
            else if (_searched && _results == null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppEmptyState(
                        title: 'No definition found',
                        message: 'We could not find "${_controller.text.trim()}" in the dictionary.',
                        icon: AppIcons.searchOff,
                        action: FilledButton.icon(
                          onPressed: () => showQuickAskSheet(
                            context,
                            ref,
                            title: 'Ask Shepherd',
                            prompt:
                                'Define the word or phrase "${_controller.text.trim()}" simply, with an example sentence.',
                          ),
                          icon: const Icon(AppIcons.sparkles, size: 18),
                          label: const Text('Ask AI Instead'),
                        ),
                      ),
                      if (_didYouMean.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text('Did you mean:', style: theme.textTheme.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            for (final s in _didYouMean) ActionChip(label: Text(s), onPressed: () => _search(s)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else if (!_searched)
              Expanded(
                child: _recentSearches.isEmpty
                    ? const AppEmptyState(
                        title: 'Look up any word',
                        message: 'Search for a word to see its definition, pronunciation, and examples.',
                        icon: AppIcons.dictionary,
                      )
                    : ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent searches', style: theme.textTheme.titleSmall),
                              TextButton(onPressed: _clearRecentSearches, child: const Text('Clear')),
                            ],
                          ),
                          for (final word in _recentSearches)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(AppIcons.clock),
                              title: Text(word),
                              onTap: () => _search(word),
                            ),
                        ],
                      ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results!.length,
                  itemBuilder: (context, index) => _DictionaryEntryCard(
                    entry: _results![index],
                    onPronounce: _pronounce,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DictionaryEntryCard extends ConsumerWidget {
  const _DictionaryEntryCard({required this.entry, required this.onPronounce});

  final DictionaryEntry entry;
  final void Function(DictionaryEntry entry) onPronounce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(child: Text(entry.word, style: theme.textTheme.headlineSmall)),
                    if (entry.phonetic != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        entry.phonetic!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              // "Ask AI" — top-right of each result, per spec.
              IconButton(
                tooltip: 'Ask AI about this word',
                onPressed: () => showQuickAskSheet(
                  context,
                  ref,
                  title: entry.word,
                  prompt: 'Explain the word "${entry.word}" in more depth, with usage tips and example sentences.',
                ),
                icon: Icon(AppIcons.sparkles, color: theme.colorScheme.primary),
              ),
              IconButton(
                tooltip: 'Play pronunciation',
                onPressed: () => onPronounce(entry),
                icon: const Icon(AppIcons.audio),
              ),
            ],
          ),
          for (final meaning in entry.meanings) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(meaning.partOfSpeech, style: theme.textTheme.labelLarge?.copyWith(fontStyle: FontStyle.italic)),
            for (final (i, def) in meaning.definitions.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${def.definition}', style: theme.textTheme.bodyMedium),
                    if (def.example != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 2),
                        child: Text(
                          '"${def.example}"',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
