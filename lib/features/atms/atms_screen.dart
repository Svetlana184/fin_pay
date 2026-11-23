import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../models/atm_location.dart';
import '../../services/atm_service.dart';
import '../../services/location_service.dart';

class AtmsScreen extends StatefulWidget {
  const AtmsScreen({super.key});

  @override
  State<AtmsScreen> createState() => _AtmsScreenState();
}

class _AtmsScreenState extends State<AtmsScreen> {
  final _atmService = AtmService();
  final _searchController = TextEditingController();

  List<AtmLocation> _atms = [];
  List<AtmLocation> _filtered = [];
  LatLng? _userPos;
  bool _loading = true;
  String? _error;

  static const _defaultCenter = LatLng(40.7831, -74.0431);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pos = await LocationService.currentPosition();
      final all = await _atmService.getAtms();

      // Фильтруем только банкоматы (atm_type == 'atm')
      final atms = all.where((a) => a.atmType == 'atm').toList();
      final list = atms.isNotEmpty ? atms : all;

      if (pos != null) {
        list.sort((a, b) => LocationService.haversine(pos, LatLng(a.latitude, a.longitude))
            .compareTo(LocationService.haversine(pos, LatLng(b.latitude, b.longitude))));
      }

      if (mounted) {
        setState(() {
          _userPos = pos;
          _atms = list;
          _filtered = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch(String value) {
    final q = value.toLowerCase();
    setState(() {
      _filtered = _atms.where((a) =>
      a.bankName.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q) ||
          (a.city ?? '').toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text('ATMs',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Stack(
        children: [
          // Карта
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _userPos ?? _defaultCenter,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.finpay.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_userPos != null)
                      Marker(
                        point: _userPos!,
                        width: 30,
                        height: 30,
                        child: const Icon(Icons.navigation,
                            color: Colors.red, size: 30),
                      ),
                    ..._filtered.map((a) => Marker(
                      point: LatLng(a.latitude, a.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.local_atm,
                          color: Color(0xFF00BCD4), size: 36),
                    )),
                  ],
                ),
              ],
            ),
          ),

          // Нижняя панель
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.25,
            maxChildSize: 0.85,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 15)
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'ATM',
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Банкоматы не найдены'))
                        : ListView.separated(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => Divider(
                          height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, i) =>
                          _atmTile(_filtered[i]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _atmTile(AtmLocation a) {
    final dist = _userPos != null
        ? LocationService.formatDistance(LocationService.haversine(
        _userPos!, LatLng(a.latitude, a.longitude)))
        : '';
    return ListTile(
      leading: const Icon(Icons.local_atm, color: Color(0xFF00BCD4)),
      title: Text('${a.bankName} ${a.address}',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${a.is247 ? '24/7' : ''} ${a.services.join(', ')}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Text(dist,
          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}