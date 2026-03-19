import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/search_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';

class SearchFormPage extends StatefulWidget {
  final SearchModel? search;

  const SearchFormPage({super.key, this.search});

  @override
  State<SearchFormPage> createState() => _SearchFormPageState();
}

class _SearchFormPageState extends State<SearchFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TextEditingController _departDateController;
  late TextEditingController _returnDateController;
  late TextEditingController _maxPriceController;

  String _currency = 'USD';

  bool get isEditing => widget.search != null;

  @override
  void initState() {
    super.initState();

    _originController =
        TextEditingController(text: widget.search?.origin ?? '');
    _destinationController =
        TextEditingController(text: widget.search?.destination ?? '');
    _departDateController =
        TextEditingController(text: widget.search?.departDate ?? '');
    _returnDateController =
        TextEditingController(text: widget.search?.returnDate ?? '');
    _maxPriceController = TextEditingController(
      text: widget.search?.maxPrice?.toString() ?? '',
    );
    _currency = widget.search?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _departDateController.dispose();
    _returnDateController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 3),
    );

    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = formatted;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final maxPrice = _maxPriceController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxPriceController.text.trim());

    bool success;

    if (isEditing) {
      success = await context.read<SearchProvider>().updateSearch(
            token: token,
            id: widget.search!.id,
            origin: _originController.text.trim(),
            destination: _destinationController.text.trim(),
            departDate: _departDateController.text.trim().isEmpty
                ? null
                : _departDateController.text.trim(),
            returnDate: _returnDateController.text.trim().isEmpty
                ? null
                : _returnDateController.text.trim(),
            currency: _currency,
            maxPrice: maxPrice,
          );
    } else {
      success = await context.read<SearchProvider>().createSearch(
            token: token,
            origin: _originController.text.trim(),
            destination: _destinationController.text.trim(),
            departDate: _departDateController.text.trim().isEmpty
                ? null
                : _departDateController.text.trim(),
            returnDate: _returnDateController.text.trim().isEmpty
                ? null
                : _returnDateController.text.trim(),
            currency: _currency,
            maxPrice: maxPrice,
          );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isEditing ? 'Search updated successfully' : 'Search created successfully')
              : (context.read<SearchProvider>().error ?? 'Operation failed'),
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<SearchProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Search' : 'Create Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  prefixIcon: Icon(Icons.flight_takeoff),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Origin is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: Icon(Icons.flight_land),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Destination is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _departDateController,
                readOnly: true,
                onTap: () => _pickDate(_departDateController),
                decoration: const InputDecoration(
                  labelText: 'Departure Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _returnDateController,
                readOnly: true,
                onTap: () => _pickDate(_returnDateController),
                decoration: const InputDecoration(
                  labelText: 'Return Date',
                  prefixIcon: Icon(Icons.event),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'JMD', child: Text('JMD')),
                  DropdownMenuItem(value: 'CAD', child: Text('CAD')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Price (optional)',
                  prefixIcon: Icon(Icons.price_check),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Update Search' : 'Save Search'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}