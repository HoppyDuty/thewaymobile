/// Reserved Hive type IDs for the CBT/offline-sync engine — matches the
/// range `phase4.md` prescribes exactly (11–17, 60). See `HiveSetup` for
/// the full allocation table across all features.
const int kHiveTypeExamType = 11;
const int kHiveTypeSubject = 12;
const int kHiveTypeTopic = 13;
const int kHiveTypeQuestion = 14;
const int kHiveTypePassageGroup = 15;
const int kHiveTypeOfflineSession = 16;
const int kHiveTypeDeltaCheckpoint = 17;
const int kHiveTypePendingOperation = 60;
