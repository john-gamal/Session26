import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import '../models/note_model.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesCubit, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Notes')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showNoteDialog(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          buildWhen: (previous, current) {
            return current is NotesLoading ||
                current is NotesSuccess ||
                current is NotesError;
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotesError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesCubit>().getNotes();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotesSuccess) {
              if (state.notes.isEmpty) {
                return const Center(
                  child: Text('No notes yet. Add your first note!'),
                );
              }

              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showNoteDialog(context, note: note);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDeleteDialog(context, note);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Loading notes...'));
          },
        ),
      ),
    );
  }

  void showNoteDialog(BuildContext context, {NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');

    final descriptionController = TextEditingController(
      text: note?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }

                final newNote = NoteModel(
                  id: note?.id ?? '',
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  isDone: note?.isDone ?? false,
                );

                if (note == null) {
                  context.read<NotesCubit>().addNote(newNote);
                } else {
                  context.read<NotesCubit>().updateNote(note.id, newNote);
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<NotesCubit>().deleteNote(note.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
