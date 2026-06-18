import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';

class NewPostPage extends ConsumerStatefulWidget {
  const NewPostPage({super.key});

  @override
  ConsumerState<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends ConsumerState<NewPostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _images = <File>[];
  String _postType = 'share';
  String? _selectedFruitId;
  bool _posting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    if (!isAuth) {
      return Scaffold(
        appBar: AppBar(title: const Text('发布')),
        body: const Center(child: Text('请先登录后再发布', style: TextStyle(fontSize: 16))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布'),
        actions: [
          TextButton(
            onPressed: _posting ? null : _submit,
            child: _posting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('发布', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'share', label: Text('晒图')),
              ButtonSegment(value: 'guide', label: Text('攻略')),
              ButtonSegment(value: 'experience', label: Text('心得')),
              ButtonSegment(value: 'question', label: Text('求助')),
            ],
            selected: {_postType},
            onSelectionChanged: (s) => setState(() => _postType = s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          if (_postType == 'guide' || _postType == 'experience') ...[
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder(), hintText: '用一句话概括'),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _contentCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: _postType == 'share' ? '分享你的水果照片和感受…' : _postType == 'question' ? '你有什么水果问题想问？' : '写下你的经验…',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _ImagePickerGrid(images: _images, onAdd: _pickImage, onRemove: (i) => setState(() => _images.removeAt(i))),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: '关联水果（可选）', border: OutlineInputBorder(), hintText: '例如：水蜜桃'),
            onChanged: (v) => setState(() => _selectedFruitId = v.isNotEmpty ? v : null),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _images.add(File(picked.path)));
  }

  Future<void> _submit() async {
    if (_posting) return;
    setState(() => _posting = true);
    try {
      final api = ref.read(apiClientProvider);
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final postData = {
        'user_id': userId,
        'type': _postType,
        'title': _titleCtrl.text,
        'content': _contentCtrl.text,
        'fruit_id': _selectedFruitId,
        'status': _postType == 'share' ? 'approved' : 'pending',
      };
      final result = await api.insert('posts', postData);
      final postId = result['id'] as int;
      if (_images.isNotEmpty) {
        for (var i = 0; i < _images.length; i++) {
          final ext = _images[i].path.split('.').last;
          final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
          await supabase.storage.from('posts').upload(fileName, _images[i]);
          final url = supabase.storage.from('posts').getPublicUrl(fileName);
          await api.insert('post_images', {'post_id': postId, 'url': url, 'sort_order': i});
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功！')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发布失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}

class _ImagePickerGrid extends StatelessWidget {
  const _ImagePickerGrid({required this.images, required this.onAdd, required this.onRemove});
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      ...images.asMap().entries.map((e) => Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8),
            child: Image.file(e.value, width: 80, height: 80, fit: BoxFit.cover)),
        Positioned(right: -4, top: -4, child: GestureDetector(
          onTap: () => onRemove(e.key),
          child: Container(padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 14, color: Colors.white)),
        )),
      ])),
      if (images.length < 9)
        GestureDetector(
          onTap: onAdd,
          child: Container(width: 80, height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300), color: Colors.grey.shade50,
            ),
            child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.grey)),
        ),
    ]);
  }
}