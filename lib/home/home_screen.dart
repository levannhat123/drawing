import 'package:drawing/home/cubit/home_cubit.dart';
import 'package:drawing/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _deleteDrawing(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red[400], size: 28),
            const SizedBox(width: 8),
            const Text('Xóa bản vẽ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa bản vẽ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<HomeCubit>().deleteDrawing(name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bản vẽ!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadDrawings(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bộ sưu tập bản vẽ'),
          centerTitle: true,
          elevation: 2,
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final drawings =
                state is HomeLoaded ? state.drawings : <DrawingItem>[];

            // Sort drawings by name in A-Z order
            final sortedDrawings = List<DrawingItem>.from(drawings)
              ..sort((a, b) => a.name.compareTo(b.name));

            if (sortedDrawings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.deepPurple[100]),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có bản vẽ nào!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hãy nhấn nút vẽ để tạo bản vẽ đầu tiên.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refreshDrawings(),
              child: GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.95,
                ),
                itemCount: sortedDrawings.length,
                itemBuilder: (context, index) {
                  final drawing = sortedDrawings[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                              context, '/draw',
                              arguments: drawing.name);
                          if (result == true) {
                            context.read<HomeCubit>().loadDrawings();
                          }
                        },
                        child: Card(
                          elevation: 6,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18)),
                                  child: drawing.thumbnail != null &&
                                          drawing.thumbnail!.isNotEmpty
                                      ? Image.memory(drawing.thumbnail!,
                                          fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.deepPurple[50],
                                          child: const Icon(Icons.image,
                                              size: 48,
                                              color: Colors.deepPurple),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    drawing.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Material(
                          color: Colors.white.withOpacity(0.85),
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 22),
                            onPressed: () =>
                                _deleteDrawing(context, drawing.name),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/draw');
            if (result == true) {
              context.read<HomeCubit>().loadDrawings();
            }
          },
          child: const Icon(Icons.draw),
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }
}
