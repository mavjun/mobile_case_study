import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  int _currentStep = 0;
  String? _selectedService;
  List<AttachedFile> _validIdFiles = [];
  List<AttachedFile> _residencyFiles = [];
  TextEditingController _additionalInfoController = TextEditingController();
  TextEditingController _purposeController = TextEditingController();
  TextEditingController _neededByController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _businessAddressController = TextEditingController();
  String? _selectedBusinessType;
  bool _isCertified = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<Service> _services = [
    Service(
      name: 'Barangay Clearance',
      description: 'For employment, business permits, and other requirements',
      fee: 'Free',
      processingTime: '15 days',
    ),
    Service(
      name: 'Business Permit',
      description: 'Application for new business or renewal',
      fee: '₱2,000',
      processingTime: '35 days',
    ),
    Service(
      name: 'Certificate of Residency',
      description: 'Proof of residency for various applications',
      fee: '₱200',
      processingTime: '8 days',
    ),
    Service(
      name: 'Barangay ID',
      description: 'Identification card for barangay residents',
      fee: '₱4,350',
      processingTime: '5 days',
    ),
    Service(
      name: 'Certificate of Indigency',
      description: 'For social welfare programs and assistance',
      fee: 'Free',
      processingTime: '25 days',
    ),
    Service(
      name: 'Other Request',
      description: 'Other barangay services or documents',
      fee: 'Varies',
      processingTime: 'Varies',
    ),
  ];

  final List<String> _businessTypes = [
    'Retail Store',
    'Restaurant/Food Business',
    'Service Provider',
    'Manufacturing',
    'Online Business',
    'Professional Services',
    'Agriculture',
    'Transportation',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 2 ? _continue : null,
        onStepCancel: _cancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Back',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      shadowColor: Colors.blueAccent,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _currentStep == 2 ? 'Submit Request' : 'Next →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },

        steps: [
          Step(
            title: const Text('Select Service'),
            content: _buildServiceSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Provide Details'),
            content: _buildDetailsForm(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Review & Submit'),
            content: _buildReviewSection(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose the type of service or document you need from the barangay.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _services.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final service = _services[index];
            return _buildServiceCard(service);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      elevation: 1,
      color: _selectedService == service.name ? Colors.blue[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedService == service.name
              ? Colors.blue[700]!
              : Colors.grey[300]!,
          width: _selectedService == service.name ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedService = service.name;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('Fee: ${service.fee}'),
                  const SizedBox(width: 8),
                  _buildInfoChip('Processing: ${service.processingTime}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purpose',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _purposeController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter the purpose of your request...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedService == 'Business Permit') ...[
          const Text(
            'Business Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Business Name *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              hintText: 'Enter your business name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Business Address *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _businessAddressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your business address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Business Type *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              hintText: 'Select business type',
            ),
            items: _businessTypes.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBusinessType = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Needed By (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _neededByController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                onTap: _selectDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Image pickers
        _buildSinglePhotoSection(
          'Valid ID',
          _validIdFiles,
          _pickValidIDImageFromGallery,
          _takeValidIDPhoto,
        ),
        const SizedBox(height: 20),
        _buildSinglePhotoSection(
          'Proof of Residence',
          _residencyFiles,
          _pickResidencyImageFromGallery,
          _takeResidencyPhoto,
        ),
        const SizedBox(height: 20),
        const Text(
          'Additional Information (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _additionalInfoController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter any additional details or notes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePhotoSection(
    String title,
    List<AttachedFile> files,
    VoidCallback pickGallery,
    VoidCallback takePhoto,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: pickGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[400],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),

        if (files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: files
                  .map((file) => _buildThumbnail(file, files))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildThumbnail(AttachedFile file, List<AttachedFile> files) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(file.path),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () {
              setState(() {
                files.remove(file);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickValidIDImageFromGallery() async {
    await _pickImage(_validIdFiles, ImageSource.gallery);
  }

  Future<void> _takeValidIDPhoto() async {
    await _pickImage(_validIdFiles, ImageSource.camera);
  }

  Future<void> _pickResidencyImageFromGallery() async {
    await _pickImage(_residencyFiles, ImageSource.gallery);
  }

  Future<void> _takeResidencyPhoto() async {
    await _pickImage(_residencyFiles, ImageSource.camera);
  }

  Future<void> _pickImage(List<AttachedFile> files, ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        final fileStat = await File(image.path).stat();
        setState(() {
          files.add(
            AttachedFile(
              name: 'photo_${files.length + 1}.jpg',
              type: 'jpg',
              size: fileStat.size,
              path: image.path,
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _neededByController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildReviewSection() {
    final selectedService = _services.firstWhere(
      (service) => service.name == _selectedService,
      orElse: () =>
          Service(name: 'None', description: '', fee: '', processingTime: ''),
    );

    final String purpose = _purposeController.text.isNotEmpty
        ? _purposeController.text
        : 'Not specified';
    final String businessType = _selectedService == 'Business Permit'
        ? (_selectedBusinessType ?? 'Not specified')
        : 'N/A';
    final String businessName = _selectedService == 'Business Permit'
        ? (_businessNameController.text.isNotEmpty
              ? _businessNameController.text
              : 'Not specified')
        : 'N/A';
    final String businessAddress = _selectedService == 'Business Permit'
        ? (_businessAddressController.text.isNotEmpty
              ? _businessAddressController.text
              : 'Not specified')
        : 'N/A';
    final String neededBy = _neededByController.text.isNotEmpty
        ? _neededByController.text
        : 'Not specified';
    final String submittedOn =
        '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSummaryItem('Service Type', selectedService.name),
          _buildSummaryItem('Purpose', purpose),
          if (_selectedService == 'Business Permit') ...[
            _buildSummaryItem('Business Name', businessName),
            _buildSummaryItem('Business Address', businessAddress),
            _buildSummaryItem('Business Type', businessType),
          ],
          _buildSummaryItem('Needed By', neededBy),
          _buildSummaryItem('Submitted On', submittedOn),
          const SizedBox(height: 16),
          const Text(
            'Attached Photos:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._validIdFiles
                  .map(
                    (f) => Image.file(
                      File(f.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                  .toList(),
              ..._residencyFiles
                  .map(
                    (f) => Image.file(
                      File(f.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                  .toList(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _isCertified,
                onChanged: (value) {
                  setState(() {
                    _isCertified = value!;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'I certify that the information provided is true and correct.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _continue() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      if (!_isCertified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please certify your request before submitting.'),
          ),
        );
        return;
      }
      // Handle submission here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
    }
  }

  void _cancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }
}

class AttachedFile {
  final String name;
  final String type;
  final int size;
  final String path;

  AttachedFile({
    required this.name,
    required this.type,
    required this.size,
    required this.path,
  });
}

class Service {
  final String name;
  final String description;
  final String fee;
  final String processingTime;

  Service({
    required this.name,
    required this.description,
    required this.fee,
    required this.processingTime,
  });
}
