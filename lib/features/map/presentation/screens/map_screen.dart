import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/group_switcher.dart';
import '../../../group/presentation/providers/group_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;

  static const _seoul = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 13,
  );

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
      body: Stack(
        children: [
          // 지도
          GoogleMap(
            initialCameraPosition: _seoul,
            onMapCreated: (c) => _controller = c,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 80,
              bottom: 100,
            ),
          ),

          // 상단 — 검색바 + 그룹 스위처
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                OrbitTokens.space20,
                OrbitTokens.space12,
                OrbitTokens.space20,
                0,
              ),
              child: Row(
                children: [
                  // 검색바
                  Expanded(
                    child: Material(
                      color: OrbitTokens.surface,
                      borderRadius:
                          BorderRadius.circular(OrbitTokens.radiusLg),
                      elevation: 2,
                      shadowColor:
                          OrbitTokens.primary.withValues(alpha: 0.08),
                      child: InkWell(
                        onTap: () {},
                        borderRadius:
                            BorderRadius.circular(OrbitTokens.radiusLg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OrbitTokens.space14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                OrbitTokens.radiusLg),
                            border: Border.all(
                                color: OrbitTokens.border, width: 0.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search,
                                  size: 18,
                                  color: OrbitTokens.primary60),
                              SizedBox(width: OrbitTokens.space10),
                              Text(
                                '장소 검색',
                                style: TextStyle(
                                  color: OrbitTokens.primary40,
                                  fontSize: OrbitTokens.fsBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (groups.isNotEmpty) ...[
                    const SizedBox(width: OrbitTokens.space8),
                    GroupSwitcher(
                      label: selectedGroupName,
                      onTap: () =>
                          _showSwitcher(context, groups, selectedGroupId),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 좌하단 내 위치 칩
          Positioned(
            left: OrbitTokens.space20,
            bottom: 100,
            child: Material(
              color: OrbitTokens.surface,
              borderRadius: BorderRadius.circular(999),
              elevation: 2,
              shadowColor: OrbitTokens.primary.withValues(alpha: 0.12),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OrbitTokens.space14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: OrbitTokens.border, width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location,
                          size: 14, color: OrbitTokens.primary60),
                      SizedBox(width: OrbitTokens.space6),
                      Text(
                        '내 위치',
                        style: TextStyle(
                          color: OrbitTokens.primary60,
                          fontSize: OrbitTokens.fsCaption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: 핀 추가
          },
          child: const Icon(Icons.add_location_alt_outlined),
        ),
      ),
    );
  }

  void _showSwitcher(
      BuildContext context, List<dynamic> groups, String? selectedId) {
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
              (g) => (
                id: g.id as String,
                name: g.name as String,
                memberCount: (g.memberIds as List).length,
              ),
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
