import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'notes';
  Future<void> getNotes() async {
    emit(NotesLoading());
    try {
      final snapshot = await firestore.collection(collectionName).get();
      final notes = snapshot.docs.map((doc) {
        return NoteModel.fromMap(doc.data(), doc.id);
      }).toList();
      emit(NotesSuccess(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> addNote(NoteModel note) async {
    if (note.title.trim().isEmpty) {
      emit(NotesError('Title cannot be empty'));
      return;
    }

    emit(NotesLoading());

    try {
      await firestore.collection(collectionName).add(note.toMap());
      await getNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> updateNote(String id, NoteModel note) async {
    if (note.title.trim().isEmpty) {
      emit(NotesError('Title cannot be empty'));
      return;
    }

    emit(NotesLoading());

    try {
      await firestore.collection(collectionName).doc(id).update(note.toMap());

      await getNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> toggleNote(String id, bool isDone) async {
    try {
      await firestore.collection(collectionName).doc(id).update({
        'isDone': isDone,
      });
      await getNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    emit(NotesLoading());

    try {
      await firestore.collection(collectionName).doc(id).delete();
      await getNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
