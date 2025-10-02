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
  List<AttachedFile> _attachedFiles = [];
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
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Submit Request' : 'Next →',
                      style: const TextStyle(color: Colors.white),
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
        // Purpose Field
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the purpose';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Business Details Section (only for Business Permit)
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

          // Business Name
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
            validator: (value) {
              if (_selectedService == 'Business Permit' &&
                  (value == null || value.isEmpty)) {
                return 'Please enter business name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Business Address
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
            validator: (value) {
              if (_selectedService == 'Business Permit' &&
                  (value == null || value.isEmpty)) {
                return 'Please enter business address';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Business Type
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
            validator: (value) {
              if (_selectedService == 'Business Permit' &&
                  (value == null || value.isEmpty)) {
                return 'Please select business type';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),
        ],

        // Needed By Field with Date Picker
        const Text(
          'Needed By (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _neededByController,
                readOnly: true, // Make the field read-only
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
                onTap: _selectDate, // Open date picker when field is tapped
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Text(
          'Upload required photos for your request',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Photo upload section
        _buildPhotoUploadSection(),

        const SizedBox(height: 20),

        // Additional information field
        const Text(
          'Additional Information (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700], // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _neededByController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Photos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedService == 'Business Permit'
              ? 'Please upload clear photos of your business documents and valid ID'
              : 'Please upload clear photos of your documents',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Photo attachment area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'Tap to attach photos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Supports: JPG, PNG (Max: 10MB)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Attached photos list
        _buildAttachedPhotosList(),
      ],
    );
  }

  Widget _buildAttachedPhotosList() {
    if (_attachedFiles.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Photos:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ..._attachedFiles.map((file) => _buildPhotoItem(file)).toList(),
      ],
    );
  }

  Widget _buildPhotoItem(AttachedFile file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.image, color: Colors.green),
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            setState(() {
              _attachedFiles.remove(file);
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final stat = await file.stat();

        setState(() {
          _attachedFiles.add(
            AttachedFile(
              name: 'photo_${_attachedFiles.length + 1}.jpg',
              type: 'jpg',
              size: stat.size,
              path: image.path,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added from gallery'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final stat = await file.stat();

        setState(() {
          _attachedFiles.add(
            AttachedFile(
              name: 'photo_${_attachedFiles.length + 1}.jpg',
              type: 'jpg',
              size: stat.size,
              path: image.path,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo taken and added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildReviewSection() {
    final selectedService = _services.firstWhere(
      (service) => service.name == _selectedService,
      orElse: () =>
          Service(name: 'None', description: '', fee: '', processingTime: ''),
    );

    // Real data from form fields
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

    // Real document status based on actual uploaded files
    final bool hasValidID = _attachedFiles.isNotEmpty;
    final bool hasProofOfResidence = _attachedFiles.length >= 2;
    final bool hasBusinessPermit = _selectedService == 'Business Permit'
        ? _attachedFiles.length >= 3
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please review your request before submitting',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Request Summary Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Center(
                  child: Text(
                    'Request Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Service Details
                _buildSummaryItem('Service Type', selectedService.name),
                _buildSummaryItem('Purpose', purpose),

                // Business Details (only for Business Permit)
                if (_selectedService == 'Business Permit') ...[
                  _buildSummaryItem('Business Name', businessName),
                  _buildSummaryItem('Business Address', businessAddress),
                  _buildSummaryItem('Business Type', businessType),
                ] else ...[
                  _buildSummaryItem('Business Type', 'N/A'),
                ],

                _buildSummaryItem('Needed By', neededBy),
                _buildSummaryItem('Submitted On', submittedOn),

                // Status
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                // Required Documents Section
                const SizedBox(height: 20),
                const Text(
                  'Required Documents:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                _buildDocumentStatus('Valid ID', hasValidID),
                _buildDocumentStatus('Proof of Residence', hasProofOfResidence),
                if (_selectedService == 'Business Permit')
                  _buildDocumentStatus('Business Documents', hasBusinessPermit),

                // Attached Photos
                if (_attachedFiles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Attached Photos:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._attachedFiles
                      .map(
                        (file) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.image,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${file.name} (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],

                // Certification Text with Checkbox
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCertified ? Colors.green[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCertified
                          ? Colors.green[300]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        child: Checkbox(
                          value: _isCertified,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCertified = value ?? false;
                            });
                          },
                          activeColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Certification Agreement',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'I certify that the information provided is true and correct. I understand that providing false information may result in penalties.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String documentName, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '• $documentName:',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Icon(
            isUploaded ? Icons.check_circle : Icons.cancel,
            color: isUploaded ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            isUploaded ? 'Uploaded' : 'Missing',
            style: TextStyle(
              fontSize: 14,
              color: isUploaded ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _continue() {
    if (_currentStep == 0 && _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 1) {
      // Validate purpose field
      if (_purposeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the purpose of your request'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate business permit fields
      if (_selectedService == 'Business Permit') {
        if (_businessNameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter business name'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_businessAddressController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter business address'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_selectedBusinessType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select business type'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _submitRequest();
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitRequest() {
    if (!_isCertified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please certify that the information provided is true and correct',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedService request submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to dashboard after submission
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    _purposeController.dispose();
    _neededByController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }
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

class AttachedFile {
  final String name;
  final String type;
  final int size; // in bytes
  final String path;

  AttachedFile({
    required this.name,
    required this.type,
    required this.size,
    required this.path,
  });
}
