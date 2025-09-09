import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SearchModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onLocationSelected;
  final Function()? onUseCurrentLocation;

  const SearchModal({
    Key? key,
    required this.onClose,
    required this.onLocationSelected,
    this.onUseCurrentLocation,
  }) : super(key: key);

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await ApiService.searchCities(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.darkCard 
                : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.darkBorder 
                  : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    language.t('search_location'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.darkSecondary 
                      : AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: language.t('search_city'),
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                    suffixIcon: _isSearching 
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: _searchCities,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Use Current Location Button
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final weatherProvider = context.read<WeatherProvider>();
                    await weatherProvider.useCurrentLocation();
                    widget.onClose();
                  },
                  icon: const Icon(Icons.my_location),
                  label: Text(language.t('use_current_location') ?? 'Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              // Search Results
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.darkSecondary 
                              : AppColors.lightSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? AppColors.darkBorder 
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            result['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '${result['state'] != null ? '${result['state']}, ' : ''}${result['country']}',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white70 
                                  : Colors.black54,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white30 
                                : Colors.black26,
                          ),
                          onTap: () => widget.onLocationSelected(result),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Popular cities when no search
              if (_searchResults.isEmpty && _searchController.text.isEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Popular cities:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.popularCities.map((city) {
                    return OutlinedButton(
                      onPressed: () => widget.onLocationSelected(city),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      child: Text(
                        city['name'],
                        style: TextStyle(color: AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}