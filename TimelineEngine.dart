
class WeddingTask {
  final String taskId;
  final String title;
  final String targetUser;
  final DateTime dueDate;
  final String ruleBaseline;
  final List<WeddingTask> subTasks;
  bool isCompleted;

  WeddingTask({
    required this.taskId,
    required this.title,
    required this.targetUser,
    required this.dueDate,
    required this.ruleBaseline,
    List<WeddingTask>? subTasks,
    this.isCompleted = false,
  }) : subTasks = subTasks ?? [];

  // Convert a Task object into a Map structure to support BaaS CRUD saving
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'targetUser': targetUser,
      'dueDate': dueDate.toIso8601String(),
      'ruleBaseline': ruleBaseline,
      'isCompleted': isCompleted,
      'subTasks': subTasks.map((task) => task.toMap()).toList(),
    };
  }

  factory WeddingTask.fromMap(Map<String, dynamic> map) {
    final rawSubTasks = map['subTasks'];
    final subTaskMaps = rawSubTasks is List ? rawSubTasks : const [];

    return WeddingTask(
      taskId: map['taskId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      targetUser: map['targetUser'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      ruleBaseline: map['ruleBaseline'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      subTasks: subTaskMaps
          .whereType<Map>()
          .map((entry) => WeddingTask.fromMap(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}

class TimelineEngine {
  /// Processes wedding input values and calculates personalized state-specific milestones
  static List<WeddingTask> generateTimeline({
    required DateTime nikahDate,
    required String state,
    required String role, // Expected inputs: 'Groom' or 'Bride'
  }) {
    List<WeddingTask> tasks = [];
    
    final normalizedState = state.trim().toLowerCase();
    final isGroom = role.trim().toLowerCase() == 'groom';

    // ----------------------------------------------------
    // 1. Universal Foundations (All States)
    // ----------------------------------------------------
    tasks.add(WeddingTask(
      taskId: 'TSK-01',
      title: 'Attend Pre-Marriage Course (Kursus Pra-Perkahwinan)',
      targetUser: 'Groom & Bride',
      dueDate: normalizedState == 'sarawak' 
          ? nikahDate.subtract(const Duration(days: 210)) 
          : nikahDate.subtract(const Duration(days: 180)),
      ruleBaseline: 'Mandatory introductory certification phase required before system authentication registration.',
    ));

    tasks.add(WeddingTask(
      taskId: 'TSK-02',
      title: 'Undergo HIV Screening at Government Clinic',
      targetUser: 'Groom & Bride',
      dueDate: normalizedState == 'sarawak'
          ? nikahDate.subtract(const Duration(days: 175))
          : nikahDate.subtract(const Duration(days: 90)),
      ruleBaseline: 'KKM physical health compliance assessment. Medical token is valid for 6 months.',
    ));

    tasks.add(WeddingTask(
      taskId: 'TSK-03',
      title: 'Gather Core Documents & Wali Identification',
      targetUser: 'Bride Only',
      dueDate: normalizedState == 'sarawak'
          ? nikahDate.subtract(const Duration(days: 172))
          : nikahDate.subtract(const Duration(days: 85)),
      ruleBaseline: 'Compile parental marriage credentials and explicit Wali documentation to avoid system file rejection.',
    ));

    // ----------------------------------------------------
    // 2. Platform Gateway Logic Parameters
    // ----------------------------------------------------
    int groomOnlineOffset = 80;
    int brideOnlineOffset = 73; 
    int endorsementOffset = 45;
    int paidSubmissionOffset = 30;
    String portalName = 'SPPIM 2.0';

    
    if (normalizedState == 'kelantan') {
      groomOnlineOffset = 85;
      brideOnlineOffset = 45;
      endorsementOffset = 30;
      paidSubmissionOffset = 15;
      portalName = 'e-Qaryah (JAHEAIK)';
    } else if (normalizedState == 'pulau pinang' || normalizedState == 'penang' || normalizedState == 'pahang') {
      groomOnlineOffset = 90;
      brideOnlineOffset = 60;
      endorsementOffset = 45;
      paidSubmissionOffset = 30;
      portalName = 'eMunakahat';
    } else if (normalizedState == 'sarawak') {
      groomOnlineOffset = 170;
      brideOnlineOffset = 120;
      endorsementOffset = 60;
      paidSubmissionOffset = 45;
      portalName = 'KISWA (SarawakID)';
    } else if (normalizedState == 'sabah') {
      groomOnlineOffset = 90;
      brideOnlineOffset = 60;
      endorsementOffset = 45;
      paidSubmissionOffset = 30;
      portalName = 'eKahwin Sabah';
    }

    // 3. Construct Tailored State Tasks
    tasks.add(WeddingTask(
      taskId: 'TSK-04',
      title: 'Initialize Online Application & Register Account on $portalName',
      targetUser: 'Groom Only',
      dueDate: nikahDate.subtract(Duration(days: groomOnlineOffset)),
      ruleBaseline: 'Primary data entry gateway access token verification criteria.',
    ));

    tasks.add(WeddingTask(
      taskId: 'TSK-05',
      title: 'Cross-Link Partner Identifier Code & Complete Bride Section on $portalName',
      targetUser: 'Bride Only',
      dueDate: nikahDate.subtract(Duration(days: brideOnlineOffset)),
      ruleBaseline: 'Relational data lookup linking the bride document schema to the groom workflow file.',
    ));

    tasks.add(WeddingTask(
      taskId: 'TSK-06',
      title: 'Print Documents and Obtain Local Kariah Imam Endorsement',
      targetUser: 'Groom & Bride',
      dueDate: nikahDate.subtract(Duration(days: endorsementOffset)),
      ruleBaseline: 'Physical administrative legal signature confirmation by local mosque assistant registrar.',
    ));

    tasks.add(WeddingTask(
      taskId: 'TSK-07',
      title: 'Submit Physical Files & Attend Interview at PAID Office',
      targetUser: 'Groom & Bride',
      dueDate: nikahDate.subtract(Duration(days: paidSubmissionOffset)),
      ruleBaseline: 'Final institutional document filing checklist, state registry fee settlement, and assessment execution.',
    ));

    // Filter collection contents based on user authentication context parameters to avoid screen clutter
    return tasks.where((task) {
      if (task.targetUser == 'Groom Only' && !isGroom) return false;
      if (task.targetUser == 'Bride Only' && isGroom) return false;
      return true;
    }).toList();
  }
}