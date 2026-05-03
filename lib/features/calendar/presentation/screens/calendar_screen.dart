import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/group_switcher.dart';
import '../../../group/presentation/providers/group_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(userGroupsProvider).value ?? [];
    final selectedGroupId = ref.watch(selectedGroupIdProvider);

    final selectedGroupName = selectedGroupId == null
        ? '전체'
        : groups
            .firstWhere(
              (g) => g.id == selectedGroupId,
              orElse: () => groups.first,
            )
            .name;

    return Scaffold(
      backgroundColor: OrbitTokens.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OrbitTokens.space20,
                OrbitTokens.space12,
                OrbitTokens.space16,
                OrbitTokens.space16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _monthLabel(_focused),
                      style: const TextStyle(
                        fontSize: OrbitTokens.fsDisplay,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: OrbitTokens.primary,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (groups.isNotEmpty)
                    GroupSwitcher(
                      label: selectedGroupName,
                      onTap: () => _showSwitcher(context, groups, selectedGroupId),
                    ),
                ],
              ),
            ),

            // 캘린더
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: OrbitTokens.space20),
              decoration: BoxDecoration(
                color: OrbitTokens.surface,
                borderRadius: BorderRadius.circular(OrbitTokens.radiusXl),
                border: Border.all(color: OrbitTokens.border, width: 0.5),
              ),
              padding: const EdgeInsets.all(OrbitTokens.space8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focused,
                selectedDayPredicate: (d) => isSameDay(_selected, d),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selected = selected;
                    _focused = focused;
                  });
                },
                onPageChanged: (focused) =>
                    setState(() => _focused = focused),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekHeight: 24,
                rowHeight: 44,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: OrbitTokens.surfaceDim,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: OrbitTokens.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: OrbitTokens.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: OrbitTokens.background,
                    fontWeight: FontWeight.w500,
                  ),
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: OrbitTokens.primary),
                  defaultTextStyle: TextStyle(color: OrbitTokens.primary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: OrbitTokens.primary40,
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    color: OrbitTokens.primary40,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: OrbitTokens.space20),

            // 선택일 일정 리스트
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  OrbitTokens.space20,
                  0,
                  OrbitTokens.space20,
                  140, // 하단 네비 + FAB
                ),
                children: [
                  Text(
                    _selected == null
                        ? '날짜를 선택하세요'
                        : '${_selected!.month}월 ${_selected!.day}일',
                    style: const TextStyle(
                      fontSize: OrbitTokens.fsLabel,
                      color: OrbitTokens.primary40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: OrbitTokens.space24),
                  if (_selected != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          '아직 일정이 없어요',
                          style: const TextStyle(
                            fontSize: OrbitTokens.fsBody,
                            color: OrbitTokens.primary40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: 일정 생성 시트
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _monthLabel(DateTime d) => '${d.year}년 ${d.month}월';

  void _showSwitcher(BuildContext context, List<dynamic> groups, String? selectedId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: OrbitTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OrbitTokens.radius2xl),
        ),
      ),
      builder: (_) => GroupSwitcherSheet(
        groups: groups
            .map<({String id, String name, int memberCount})>(
              (g) => (id: g.id as String, name: g.name as String, memberCount: (g.memberIds as List).length),
            )
            .toList(),
        selectedGroupId: selectedId,
        onSelected: (id) {
          ref.read(selectedGroupIdProvider.notifier).state = id;
        },
      ),
    );
  }
}
