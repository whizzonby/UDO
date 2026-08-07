import 'package:flutter/material.dart';
import 'udo_design_system.dart';

String? _humanizeStatus(String? value) {
  if (value == null || value.isEmpty) return null;
  return '${value[0].toUpperCase()}${value.substring(1).replaceAll('_', ' ')}';
}

/// The pink/rose "Your Wedding Party" overview layout — shared between the
/// lightweight Plan-tab preview (which always pushes into the full
/// `/wedding-party` screen regardless of which tile was tapped) and the real
/// standalone screen's own Overview tab (which jumps between its own tabs).
///
/// [onOpenModule] receives one of: `overview`, `responsibilities`,
/// `rehearsal`, `travel`, `files`, `people`. Callers that don't distinguish
/// between them (the Plan-tab preview) can ignore the key.
class WeddingPartyOverview extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> responsibilities;
  final List<Map<String, dynamic>> buzzes;
  final List<Map<String, dynamic>> timelineItems;
  final List<Map<String, dynamic>> accommodations;
  final List<Map<String, dynamic>> transportGroups;
  final List<Map<String, dynamic>> files;
  final int attireReady;
  final int rehearsalConfirmed;
  final int travelConfirmed;
  final int readyCount;
  final int openResponsibilities;
  final List<Map<String, dynamic>> priorityTasks;
  final String Function(Map<String, dynamic> member) initialsFor;
  final void Function(String moduleKey) onOpenModule;

  /// When supplied, tapping a member opens their detail view instead of
  /// falling back to `onOpenModule('people')`.
  final void Function(String memberId)? onPersonTap;

  /// Extra content appended after the Members list — e.g. the real screen's
  /// "Send a buzz" quick actions. The Plan-tab preview leaves this null.
  final Widget? trailingSection;

  const WeddingPartyOverview({
    super.key,
    required this.isLoading,
    required this.error,
    required this.members,
    required this.responsibilities,
    required this.buzzes,
    required this.timelineItems,
    required this.accommodations,
    required this.transportGroups,
    required this.files,
    required this.attireReady,
    required this.rehearsalConfirmed,
    required this.travelConfirmed,
    required this.readyCount,
    required this.openResponsibilities,
    required this.priorityTasks,
    required this.initialsFor,
    required this.onOpenModule,
    this.onPersonTap,
    this.trailingSection,
  });

  String _name(Map<String, dynamic> member) {
    final first = (member['first_name'] ?? '').toString().trim();
    final last = (member['last_name'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    return full.isEmpty ? 'Wedding party member' : full;
  }

  String _role(Map<String, dynamic> member) =>
      (member['wedding_party_role'] ?? 'Wedding party').toString();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: UdoDesign.rose));
    }

    final readiness =
        members.isEmpty ? 0 : ((readyCount / members.length) * 100).round();
    final roles = <String, int>{};
    for (final member in members) {
      final role = _role(member);
      roles[role] = (roles[role] ?? 0) + 1;
    }
    final rehearsalItems = timelineItems.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final type = (item['event_type'] ?? '').toString().toLowerCase();
      return title.contains('rehearsal') || type.contains('rehearsal');
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        if (error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UdoDesign.rose.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UdoDesign.rose.withValues(alpha: 0.18)),
            ),
            child: Text("Couldn't load wedding party members.",
                style: UdoDesign.sans(size: 13, color: UdoDesign.rose)),
          ),
        _WeddingPartyHeroCard(
          readiness: readiness,
          members: members.length,
          readyCount: readyCount,
          openResponsibilities: openResponsibilities,
          onTap: () => onOpenModule('overview'),
        ),
        const SizedBox(height: 14),
        _WeddingPartyOpsGrid(
          attireReady: attireReady,
          rehearsalConfirmed: rehearsalConfirmed,
          travelConfirmed: travelConfirmed,
          buzzes: buzzes.length,
          members: members.length,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Party operations',
          subtitle: 'Responsibilities, outfits, rehearsal, travel, files',
          action: 'Open',
          onAction: () => onOpenModule('overview'),
        ),
        _WeddingPartyModuleGrid(
          openResponsibilities: openResponsibilities,
          rehearsalCount: rehearsalItems.length,
          accommodations: accommodations.length,
          transportGroups: transportGroups.length,
          files: files.length,
          onOpenModule: onOpenModule,
        ),
        const SizedBox(height: 18),
        if (priorityTasks.isNotEmpty) ...[
          UdoSectionHeader(
            title: "Today's priorities",
            subtitle:
                '${priorityTasks.length} responsibility${priorityTasks.length == 1 ? '' : 'ies'} needing action',
          ),
          for (final task in priorityTasks) _WeddingPartyTaskRow(task: task),
          const SizedBox(height: 18),
        ],
        UdoSectionHeader(
          title: 'Role coverage',
          subtitle:
              '${roles.length} role${roles.length == 1 ? '' : 's'} assigned',
        ),
        if (roles.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.groups_2_outlined,
                  size: 36, color: UdoDesign.amber),
              const SizedBox(height: 10),
              Text('No wedding party members yet',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                'Add members, roles, outfits, responsibilities, and rehearsal details in the full module.',
                textAlign: TextAlign.center,
                style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => onOpenModule('overview'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open Wedding Party'),
              ),
            ]),
          )
        else ...[
          _WeddingPartyRoleStrip(roles: roles),
          const SizedBox(height: 18),
          UdoSectionHeader(
            title: 'Members',
            subtitle: '${members.length} people coordinating the day',
          ),
          for (final member in members.take(6))
            _WeddingPartyMemberCard(
              name: _name(member),
              role: _role(member),
              initials: initialsFor(member),
              attireStatus: (member['attire_status'] ?? 'pending').toString(),
              rehearsalStatus:
                  (member['rehearsal_status'] ?? 'pending').toString(),
              travelReady: member['travel_required'] != true ||
                  member['hotel_assignment_id'] != null ||
                  member['transport_assignment_id'] != null,
              onTap: () {
                final id = member['id']?.toString();
                if (onPersonTap != null && id != null) {
                  onPersonTap!(id);
                } else {
                  onOpenModule('people');
                }
              },
            ),
        ],
        if (trailingSection != null) ...[
          const SizedBox(height: 18),
          trailingSection!,
        ],
      ],
    );
  }
}

class _WeddingPartyHeroCard extends StatelessWidget {
  final int readiness;
  final int members;
  final int readyCount;
  final int openResponsibilities;
  final VoidCallback onTap;

  const _WeddingPartyHeroCard({
    required this.readiness,
    required this.members,
    required this.readyCount,
    required this.openResponsibilities,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      color: UdoDesign.rose,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        UdoRingProgress(
          value: readiness / 100,
          size: 64,
          color: Colors.white,
          center: Text('$readiness%',
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your Wedding Party',
                style: UdoDesign.sans(
                    size: 17, weight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Everyone knows what comes next',
                style: UdoDesign.serif(
                    size: 22, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              '$readyCount of $members fully ready · $openResponsibilities open tasks',
              style: UdoDesign.sans(
                  size: 12.5, color: Colors.white.withValues(alpha: 0.76)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _WeddingPartyOpsGrid extends StatelessWidget {
  final int attireReady;
  final int rehearsalConfirmed;
  final int travelConfirmed;
  final int buzzes;
  final int members;

  const _WeddingPartyOpsGrid({
    required this.attireReady,
    required this.rehearsalConfirmed,
    required this.travelConfirmed,
    required this.buzzes,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        'Attire',
        '$attireReady/$members',
        Icons.checkroom_outlined,
        UdoDesign.rose
      ),
      (
        'Rehearsal',
        '$rehearsalConfirmed/$members',
        Icons.event_outlined,
        UdoDesign.gold
      ),
      (
        'Travel',
        '$travelConfirmed/$members',
        Icons.flight_outlined,
        UdoDesign.blue
      ),
      ('Buzzes', '$buzzes', Icons.campaign_outlined, UdoDesign.sage),
    ];
    return Row(children: [
      for (final metric in metrics)
        Expanded(
          child: UdoCard(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(children: [
              Icon(metric.$3, size: 18, color: metric.$4),
              const SizedBox(height: 5),
              Text(metric.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(
                      size: 13, weight: FontWeight.w800, color: metric.$4)),
              Text(metric.$1,
                  style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
            ]),
          ),
        ),
    ]);
  }
}

class _WeddingPartyModuleGrid extends StatelessWidget {
  final int openResponsibilities;
  final int rehearsalCount;
  final int accommodations;
  final int transportGroups;
  final int files;
  final void Function(String moduleKey) onOpenModule;

  const _WeddingPartyModuleGrid({
    required this.openResponsibilities,
    required this.rehearsalCount,
    required this.accommodations,
    required this.transportGroups,
    required this.files,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final modules = [
      (
        'Responsibilities',
        '$openResponsibilities open',
        Icons.checklist_outlined,
        'responsibilities',
      ),
      (
        'Rehearsal',
        '$rehearsalCount events',
        Icons.event_available_outlined,
        'rehearsal',
      ),
      (
        'Accommodation',
        '$accommodations records',
        Icons.hotel_outlined,
        'travel',
      ),
      (
        'Transport',
        '$transportGroups groups',
        Icons.directions_bus_outlined,
        'travel',
      ),
      ('Files', '$files files', Icons.folder_open_outlined, 'files'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final module in modules)
          SizedBox(
            width: (MediaQuery.sizeOf(context).width - 48) / 2,
            child: UdoCard(
              onTap: () => onOpenModule(module.$4),
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(module.$3, size: 18, color: UdoDesign.rose),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(module.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UdoDesign.sans(
                                size: 12.5, weight: FontWeight.w800)),
                        Text(module.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UdoDesign.sans(
                                size: 11, color: UdoDesign.muted)),
                      ]),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

class _WeddingPartyTaskRow extends StatelessWidget {
  final Map<String, dynamic> task;
  const _WeddingPartyTaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      child: Row(children: [
        const Icon(Icons.priority_high_rounded,
            size: 18, color: UdoDesign.rose),
        const SizedBox(width: 10),
        Expanded(
          child: Text((task['title'] ?? 'Responsibility').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 13, weight: FontWeight.w700)),
        ),
        if (task['due_date'] != null)
          Text(task['due_date'].toString(),
              style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
      ]),
    );
  }
}

class _WeddingPartyRoleStrip extends StatelessWidget {
  final Map<String, int> roles;
  const _WeddingPartyRoleStrip({required this.roles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final entry = roles.entries.elementAt(index);
          return Container(
            width: 138,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UdoDesign.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UdoDesign.stone),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.value.toString(),
                  style: UdoDesign.sans(
                      size: 18,
                      weight: FontWeight.w800,
                      color: UdoDesign.rose)),
              const SizedBox(height: 3),
              Text(entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: roles.length,
      ),
    );
  }
}

class _WeddingPartyMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  final String attireStatus;
  final String rehearsalStatus;
  final bool travelReady;
  final VoidCallback onTap;

  const _WeddingPartyMemberCard({
    required this.name,
    required this.role,
    required this.initials,
    required this.attireStatus,
    required this.rehearsalStatus,
    required this.travelReady,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ready = attireStatus == 'ready' &&
        rehearsalStatus == 'confirmed' &&
        travelReady;
    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: UdoDesign.rose.withValues(alpha: 0.12),
          child: Text(initials,
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w800, color: UdoDesign.rose)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
              ),
              UdoBadge(
                  label: ready ? 'Ready' : 'Needs work',
                  color: ready ? UdoDesign.sage : UdoDesign.amber),
            ]),
            const SizedBox(height: 3),
            Text(role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _WeddingPartySignal(
                  label: _humanizeStatus(attireStatus) ?? 'Attire',
                  color: attireStatus == 'ready'
                      ? UdoDesign.sage
                      : UdoDesign.amber),
              _WeddingPartySignal(
                  label: _humanizeStatus(rehearsalStatus) ?? 'Rehearsal',
                  color: rehearsalStatus == 'confirmed'
                      ? UdoDesign.sage
                      : UdoDesign.amber),
              _WeddingPartySignal(
                  label: travelReady ? 'Travel ready' : 'Travel pending',
                  color: travelReady ? UdoDesign.sage : UdoDesign.rose),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _WeddingPartySignal extends StatelessWidget {
  final String label;
  final Color color;
  const _WeddingPartySignal({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: UdoDesign.sans(
              size: 10.5, weight: FontWeight.w700, color: color)),
    );
  }
}
