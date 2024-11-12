import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasks(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await _tasksCollection.doc(taskId).update(updates);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> addSubTask(String taskId, SubTask subTask) async {
    final taskDoc = await _tasksCollection.doc(taskId).get();
    final task = Task.fromMap(taskDoc.data() as Map<String, dynamic>);
    task.subTasks.add(subTask);
    await _tasksCollection.doc(taskId).update({'subTasks': task.subTasks.map((st) => st.toMap()).toList()});
  }

  Future<void> updateSubTask(
    String taskId,
    String subTaskId,
    Map<String, dynamic> updates,
  ) async {
    final taskDoc = await _tasksCollection.doc(taskId).get();
    final task = Task.fromMap(taskDoc.data() as Map<String, dynamic>);
    final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
    if (subTaskIndex != -1) {
      updates.forEach((key, value) {
        switch (key) {
          case 'isCompleted':
            task.subTasks[subTaskIndex].isCompleted = value;
            break;
          case 'title':
            task.subTasks[subTaskIndex].title = value;
            break;
          case 'timeSlot':
            task.subTasks[subTaskIndex].timeSlot = value;
            break;
        }
      });
      await _tasksCollection.doc(taskId).update(
        {'subTasks': task.subTasks.map((st) => st.toMap()).toList()},
      );
    }
  }

  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final taskDoc = await _tasksCollection.doc(taskId).get();
    final task = Task.fromMap(taskDoc.data() as Map<String, dynamic>);
    task.subTasks.removeWhere((st) => st.id == subTaskId);
    await _tasksCollection.doc(taskId).update(
      {'subTasks': task.subTasks.map((st) => st.toMap()).toList()},
    );
  }
}