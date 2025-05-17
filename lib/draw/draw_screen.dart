import 'package:drawing/draw/cubit/draw_cubit.dart';
import 'package:drawing/draw/cubit/draw_state.dart';
import 'package:drawing/draw/draw_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  @override
  Widget build(BuildContext context) {
    final String? drawingName =
        ModalRoute.of(context)?.settings.arguments as String?;

    return BlocProvider(
      create: (context) => DrawCubit()..initialize(drawingName),
      child: BlocBuilder<DrawCubit, DrawState>(
        builder: (context, state) {
          final cubit = context.read<DrawCubit>();

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
              title: Text(
                state.drawingName ?? 'Vẽ ý tưởng',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              actions: [
                Tooltip(
                  message: 'Tải bản vẽ về',
                  child: IconButton(
                    icon: const Icon(Icons.download, size: 28),
                    onPressed: () async {
                      final message = await cubit.downloadDrawing();
                      if (message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onPanStart: (details) =>
                          cubit.startStroke(details.localPosition),
                      onPanUpdate: (details) =>
                          cubit.updateStroke(details.localPosition),
                      onPanEnd: (_) => cubit.endStroke(),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DrawPainter(
                          state.strokes,
                          state.currentPoints,
                          state.brushSize,
                          state.isErasing ? Colors.white : state.selectedColor,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildToolBottomBar(context, state, cubit),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 100,
              ),
              child: FloatingActionButton(
                elevation: 8,
                backgroundColor: Colors.deepPurple,
                shape: const CircleBorder(),
                child: const Icon(Icons.save, color: Colors.white, size: 32),
                onPressed: () => _showSaveDialog(context, cubit, drawingName),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolBottomBar(
      BuildContext context, DrawState state, DrawCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolIcon(
                  icon: Icons.undo,
                  onTap: state.strokes.isNotEmpty ? cubit.undo : null,
                  selected: false,
                ),
                _buildToolIcon(
                  icon: Icons.redo,
                  onTap: state.redoStrokes.isNotEmpty ? cubit.redo : null,
                  selected: false,
                ),
                _buildToolIcon(
                  icon: Icons.brush,
                  onTap: () => cubit.changeColor(Colors.black),
                  selected: !state.isErasing,
                ),
                _buildToolIcon(
                  icon: Icons.color_lens,
                  iconColor: state.selectedColor,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn màu'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: state.selectedColor,
                              onColorChanged: cubit.changeColor,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Xong'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  selected: false,
                ),
                _buildToolIcon(
                  icon: Icons.auto_fix_high,
                  onTap: cubit.toggleEraser,
                  selected: state.isErasing,
                ),
              ],
            ),
          ),
          Slider(
            value: state.brushSize,
            min: 1,
            max: 20,
            divisions: 19,
            label: state.brushSize.round().toString(),
            onChanged: cubit.changeBrushSize,
            activeColor: Colors.deepPurple,
            thumbColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon({
    required IconData icon,
    required VoidCallback? onTap,
    bool selected = false,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected
                ? Colors.deepPurple.withOpacity(0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color:
                iconColor ?? (selected ? Colors.deepPurple : Colors.grey[700]),
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(
      BuildContext context, DrawCubit cubit, String? drawingName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(drawingName != null ? 'Cập nhật bản vẽ' : 'Lưu bản vẽ'),
          content: TextField(
            controller: cubit.state.textController,
            decoration: InputDecoration(
              hintText: drawingName ?? 'Nhập tên cho bản vẽ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (cubit.state.textController.text.isNotEmpty) {
                  await cubit.saveDrawing();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: true, // Báo hiệu rằng bản vẽ đã được lưu
                  );
                }
              },
              child: Text(drawingName != null ? 'Cập nhật' : 'Lưu'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}
