import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'app_state.dart';
import 'colors.dart';
import 'models.dart';
import 'dart:async';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.watch<AppState>();
    if (_controllers.length != appState.products.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers = List.generate(
        appState.products.length,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      );
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) _controllers[i].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Management',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your flower inventory',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Products Grid - Almost there! Just 16px more
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.56, // Final adjustment for 16px
              ),
              itemCount: appState.products.length,
              itemBuilder: (context, index) {
                if (index >= _controllers.length) return const SizedBox();

                return FadeTransition(
                  opacity: _controllers[index],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controllers[index],
                      curve: Curves.easeOut,
                    )),
                    child: _buildProductCard(appState.products[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductModal(context),
        backgroundColor: teal400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  

  Widget _buildProductCard(Product product) {
    final appState = context.read<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - FIXED: Smaller aspect ratio
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 1.3, // Wider and shorter image
              child: _buildProductImage(product.imageUrl),
            ),
          ),
          // Info - FIXED: More compact padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name - FIXED: maxLines with ellipsis
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: teal900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Price
                  Text(
                    formatRupiah(product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: purple600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Stock
                  Text(
                    'Stock: ${product.stock}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: teal600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: orange50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: orange100),
                    ),
                    child: Text(
                      'Terjual: ${product.sold}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: orange600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Action Buttons - FIXED: More compact
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await appState.updateStock(product.id, -1);
                          },
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: red100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.remove,
                                color: red600, size: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await appState.updateStock(product.id, 1);
                          },
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: green100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add,
                                color: green600, size: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _showSoldProductModal(context, product, appState);
                          },
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: orange100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.sell,
                                color: orange600, size: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          _showEditProductModal(context, product);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: teal100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:
                              const Icon(Icons.edit, color: teal600, size: 14),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text('Delete "${product.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await appState.deleteProduct(product.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Product deleted successfully!'),
                                      ),
                                    );
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: red600)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: red100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.delete,
                              color: red600, size: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    // Prioritas: asset path (packaged), kemudian file lokal yang dipilih user, selain itu fallback placeholder
    if (imageUrl.isEmpty || imageUrl.startsWith('http')) {
      return _buildDefaultImage();
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultImage(),
      );
    }
    // Asumsikan path file lokal (hasil picker / kamera)
    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultImage(),
      );
    }
    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [teal100, purple100],
        ),
      ),
      child: const Icon(Icons.local_florist, size: 40, color: teal400),
    );
  }

  void _showAddProductModal(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Product',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: teal900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: gray100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Photo Selection Row: Camera & Gallery
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: 1280,
                                maxHeight: 1280,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setModalState(() => selectedImage = image);
                              } else {
                                // Fallback ke galeri jika kamera batal/null
                                final XFile? gallery = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1280,
                                  maxHeight: 1280,
                                  imageQuality: 85,
                                );
                                if (gallery != null) {
                                  setModalState(() => selectedImage = gallery);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kamera tidak tersedia, gunakan foto galeri.')),
                                    );
                                  }
                                }
                              }
                            } catch (e) {
                              // Jika exception (PlatformException) fallback ke galeri
                              try {
                                final XFile? gallery = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1280,
                                  maxHeight: 1280,
                                  imageQuality: 85,
                                );
                                if (gallery != null) {
                                  setModalState(() => selectedImage = gallery);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal akses kamera: $e')),
                                  );
                                }
                              } catch (_) {}
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: selectedImage != null ? teal100 : gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedImage != null ? teal400 : gray100,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera_outlined,
                                      color: selectedImage != null ? teal600 : gray400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedImage != null ? 'Foto Dipilih' : 'Kamera',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: selectedImage != null ? teal600 : gray400,
                                      fontWeight: selectedImage != null ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1280,
                              maxHeight: 1280,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              setModalState(() => selectedImage = image);
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: selectedImage != null ? teal100 : gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedImage != null ? teal400 : gray100,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      color: selectedImage != null ? teal600 : gray400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedImage != null ? 'Foto Dipilih' : 'Galeri',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: selectedImage != null ? teal600 : gray400,
                                      fontWeight: selectedImage != null ? FontWeight.w600 : FontWeight.w500,
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
                  const SizedBox(height: 16),
                  _buildModalTextField(nameController, 'Product Name'),
                  const SizedBox(height: 16),
                    _buildModalTextField(priceController, 'Base Price', prefix: 'Rp '),
                  const SizedBox(height: 16),
                  _buildModalTextField(quantityController, 'Quantity'),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        final appState = context.read<AppState>();
                        // Generate unique ID based on max existing ID
                        int maxId = appState.products.isEmpty 
                            ? 0 
                            : appState.products.map((p) => p.id).reduce((a, b) => a > b ? a : b);
                        final newProduct = Product(
                          id: maxId + 1,
                          name: nameController.text,
                          price: double.tryParse(priceController.text) ?? 0,
                          stock: int.tryParse(quantityController.text) ?? 0,
                          imageUrl: selectedImage?.path ?? '',
                          materials: '', // materials removed from create UI
                        );
                        await appState.addProduct(newProduct);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product added successfully!')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Save Product',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductModal(BuildContext context, Product product) {
    final appState = context.read<AppState>();
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final quantityController = TextEditingController(text: product.stock.toString());
    final materialsController = TextEditingController(text: product.materials);
    XFile? updatedImage; // allow replacing image
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Product',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: teal900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: gray100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Camera / Gallery row for updating product image
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: 1280,
                                maxHeight: 1280,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setModalState(() => updatedImage = image);
                              } else {
                                final XFile? gallery = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1280,
                                  maxHeight: 1280,
                                  imageQuality: 85,
                                );
                                if (gallery != null) {
                                  setModalState(() => updatedImage = gallery);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kamera tidak tersedia, gunakan foto galeri.')),
                                    );
                                  }
                                }
                              }
                            } catch (e) {
                              try {
                                final XFile? gallery = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1280,
                                  maxHeight: 1280,
                                  imageQuality: 85,
                                );
                                if (gallery != null) {
                                  setModalState(() => updatedImage = gallery);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal akses kamera: $e')),
                                  );
                                }
                              } catch (_) {}
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: updatedImage != null ? teal100 : gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: updatedImage != null ? teal400 : gray100,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera_outlined,
                                      color: updatedImage != null ? teal600 : gray400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    updatedImage != null ? 'Foto Baru' : 'Kamera',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: updatedImage != null ? teal600 : gray400,
                                      fontWeight: updatedImage != null ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1280,
                              maxHeight: 1280,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              setModalState(() => updatedImage = image);
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: updatedImage != null ? teal100 : gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: updatedImage != null ? teal400 : gray100,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      color: updatedImage != null ? teal600 : gray400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    updatedImage != null ? 'Foto Baru' : 'Galeri',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: updatedImage != null ? teal600 : gray400,
                                      fontWeight: updatedImage != null ? FontWeight.w600 : FontWeight.w500,
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
                  const SizedBox(height: 24),
                  _buildModalTextField(nameController, 'Product Name'),
                  const SizedBox(height: 16),
                  _buildModalTextField(priceController, 'Base Price', prefix: 'Rp '),
                  const SizedBox(height: 16),
                  _buildModalTextField(materialsController, 'Materials'),
                  const SizedBox(height: 16),
                  _buildModalTextField(quantityController, 'Quantity'),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        final updatedProduct = Product(
                          id: product.id,
                          name: nameController.text,
                          price: double.tryParse(priceController.text) ?? 0,
                          stock: int.tryParse(quantityController.text) ?? 0,
                          imageUrl: updatedImage?.path ?? product.imageUrl,
                          materials: materialsController.text,
                        );
                        await appState.updateProduct(updatedProduct);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product updated successfully!')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Update Product',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSoldProductModal(BuildContext context, Product product, AppState appState) {
    TextEditingController soldQtyController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Catat Produk Terjual',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Produk: ${product.name}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: teal600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Harga Satuan: Rp ${formatRupiah(product.price)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Jumlah Terjual',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _buildModalTextField(soldQtyController, 'Jumlah'),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  int qty = int.tryParse(soldQtyController.text) ?? 1;
                  if (qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jumlah harus lebih dari 0')),);
                    return;
                  }
                  if (qty > product.stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stok tersedia hanya ${product.stock}')),);
                    return;
                  }
                  await appState.recordProductSold(product.id, qty);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$qty ${product.name} tercatat terjual!'),
                      backgroundColor: green600,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: orange600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Catat Terjual',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(TextEditingController controller, String hint,
      {String? prefix}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gray100),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            prefix != null ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ============= STOCK MANAGEMENT SCREEN =============
class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  // Kalkulator Bahan Baku state
  int? _selectedMaterialId;
  final TextEditingController _calcQtyController = TextEditingController(text: '1');
  final TextEditingController _marginController = TextEditingController(text: '30');
  final TextEditingController _otherCostController = TextEditingController(text: '0');
  // Each line: { 'materialId': int, 'qty': int }
  final List<Map<String, int>> _calcLines = [];

  @override
  void initState() {
    super.initState();
    _controllers = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.watch<AppState>();
    if (_controllers.length != appState.materials.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers = List.generate(
        appState.materials.length,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      );
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) _controllers[i].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _calcQtyController.dispose();
    _marginController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Stok',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola material dan perlengkapan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Kalkulator + Materials List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: appState.materials.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCostCalculator(appState),
                  );
                }
                final matIndex = index - 1;
                if (matIndex >= _controllers.length) return const SizedBox();
                return FadeTransition(
                  opacity: _controllers[matIndex],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controllers[matIndex],
                      curve: Curves.easeOut,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMaterialCard(appState.materials[matIndex]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMaterialModal(context),
        backgroundColor: teal400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCostCalculator(AppState appState) {
    double totalCost = 0;
    for (final line in _calcLines) {
      final mat = appState.materials.firstWhere(
        (m) => m.id == line['materialId'],
        orElse: () => MaterialItem(id: -1, name: 'Unknown', unitPrice: 0, quantity: 0, unit: ''),
      );
      final qty = line['qty'] ?? 0;
      totalCost += mat.unitPrice * qty;
    }

    final margin = double.tryParse(_marginController.text) ?? 0;
    final other = double.tryParse(_otherCostController.text) ?? 0;
    final suggested = (totalCost + other) * (1 + margin / 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalkulator Biaya Bahan Baku',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: teal900,
                ),
              ),
              if (_calcLines.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _calcLines.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Reset', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gray100),
                  ),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedMaterialId,
                    underline: const SizedBox.shrink(),
                    hint: Text('Pilih Material', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                    items: appState.materials.map((m) {
                      return DropdownMenuItem<int>(
                        value: m.id,
                        child: Text('${m.name} • ${formatRupiah(m.unitPrice)}', style: GoogleFonts.poppins(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMaterialId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gray100),
                  ),
                  child: TextField(
                    controller: _calcQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Qty',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_selectedMaterialId == null) return;
                  final qty = int.tryParse(_calcQtyController.text) ?? 0;
                  if (qty <= 0) return;
                  setState(() {
                    _calcLines.add({'materialId': _selectedMaterialId!, 'qty': qty});
                  });
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: teal100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: teal600, size: 16),
                      const SizedBox(width: 6),
                      Text('Tambah', style: GoogleFonts.poppins(color: teal600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_calcLines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: _calcLines.asMap().entries.map((entry) {
                final i = entry.key;
                final line = entry.value;
                final mat = appState.materials.firstWhere(
                  (m) => m.id == line['materialId'],
                  orElse: () => MaterialItem(id: -1, name: 'Unknown', unitPrice: 0, quantity: 0, unit: ''),
                );
                final qty = line['qty'] ?? 0;
                final subtotal = mat.unitPrice * qty;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gray100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mat.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('${formatRupiah(mat.unitPrice)} / unit', style: GoogleFonts.poppins(fontSize: 11, color: teal600)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Qty',
                            isDense: true,
                          ),
                          onChanged: (v) {
                            setState(() {
                              line['qty'] = int.tryParse(v) ?? qty;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(formatRupiah(subtotal), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: purple600)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _calcLines.removeAt(i)),
                        child: const Icon(Icons.close, size: 18, color: red600),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Margin (%)', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: gray50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gray100),
                        ),
                        child: TextField(
                          controller: _marginController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biaya Lain (Rp)', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: gray50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gray100),
                        ),
                        child: TextField(
                          controller: _otherCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Biaya', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                Text(formatRupiah(totalCost), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: teal900)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saran Harga Jual', style: GoogleFonts.poppins(fontSize: 12, color: teal600)),
                Text(formatRupiah(suggested), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: purple600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialItem material) {
    final appState = context.read<AppState>();
    final priceController =
        TextEditingController(text: material.unitPrice.toStringAsFixed(2));
    final quantityController =
        TextEditingController(text: material.quantity.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.toggleMaterialEdit(material.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: teal100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        material.isEditing ? Icons.check : Icons.edit,
                        color: teal600,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => appState.deleteMaterial(material.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: red100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: red600, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Satuan (Rp)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: teal600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    material.isEditing
                        ? Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: teal100),
                            ),
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                material.unitPrice = double.tryParse(value) ??
                                    material.unitPrice;
                              },
                            ),
                          )
                        : Text(
                            formatRupiah(material.unitPrice),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: teal900,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: teal600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    material.isEditing
                        ? Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: teal100),
                            ),
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                material.quantity =
                                    int.tryParse(value) ?? material.quantity;
                              },
                            ),
                          )
                        : Text(
                            '${material.quantity}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: teal900,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          if (material.quantity < 50)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: orange50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, size: 16, color: orange600),
                    const SizedBox(width: 8),
                    Text(
                      'Stok terbatas',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: orange600,
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

  void _showAddMaterialModal(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambah Material Baru',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: teal900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: gray100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModalTextField(nameController, 'Nama Material'),
                  const SizedBox(height: 16),
                  _buildModalTextField(priceController, 'Harga Satuan',
                      prefix: 'Rp '),
                  const SizedBox(height: 16),
                  _buildModalTextField(quantityController, 'Jumlah'),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        final appState = context.read<AppState>();
                        // Generate unique ID based on max existing ID
                        int maxId = appState.materials.isEmpty 
                            ? 0 
                            : appState.materials.map((m) => m.id).reduce((a, b) => a > b ? a : b);
                        final newMaterial = MaterialItem(
                          id: maxId + 1,
                          name: nameController.text,
                          unitPrice: double.tryParse(priceController.text) ?? 0,
                          quantity: int.tryParse(quantityController.text) ?? 0,
                          unit: '',
                          imageUrl: null,
                        );
                        await appState.addMaterial(newMaterial);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Material ditambahkan!')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Simpan Material',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(TextEditingController controller, String hint,
      {String? prefix}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gray100),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            prefix != null ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
