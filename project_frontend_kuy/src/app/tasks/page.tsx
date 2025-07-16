'use client';

import { useEffect, useState } from 'react';
import axios from '@/lib/axios';

type Task = {
  id: number;
  title: string;
  status: 'pending' | 'done';
};

export default function TaskPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [newTask, setNewTask] = useState('');
  const [editMode, setEditMode] = useState<number | null>(null);
  const [editTitle, setEditTitle] = useState('');

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const res = await axios.get('/tasks');
      setTasks(res.data);
    } catch (error) {
      console.error('Error fetching tasks:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  const handleAddTask = async () => {
    if (!newTask.trim()) return;
    try {
      await axios.post('/tasks', {
        title: newTask,
        status: 'pending',
      });
      setNewTask('');
      fetchTasks();
    } catch (error) {
      console.error('Error adding task:', error);
    }
  };

  const handleToggleStatus = async (task: Task) => {
    try {
      await axios.put(`/tasks/${task.id}`, {
        title: task.title,
        status: task.status === 'done' ? 'pending' : 'done',
      });
      fetchTasks();
    } catch (error) {
      console.error('Error toggling status:', error);
    }
  };

  const handleDeleteTask = async (id: number) => {
    try {
      await axios.delete(`/tasks/${id}`);
      fetchTasks();
    } catch (error) {
      console.error('Error deleting task:', error);
    }
  };

  const handleEditTask = (task: Task) => {
    setEditMode(task.id);
    setEditTitle(task.title);
  };

  const handleUpdateTask = async (id: number) => {
    if (!editTitle.trim()) return;
    try {
      await axios.put(`/tasks/${id}`, {
        title: editTitle,
        status: tasks.find(t => t.id === id)?.status || 'pending',
      });
      setEditMode(null);
      setEditTitle('');
      fetchTasks();
    } catch (error) {
      console.error('Error updating task:', error);
    }
  };

  return (
    <div className="max-w-3xl mx-auto mt-10 p-4">
      <h1 className="text-3xl font-bold mb-6">Task Management</h1>

      <div className="mb-6 flex gap-2">
        <input
          type="text"
          placeholder="New Task Title"
          className="flex-1 p-2 border rounded"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
        />
        <button
          onClick={handleAddTask}
          className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
        >
          Add Task
        </button>
      </div>

      {loading ? (
        <p>Loading...</p>
      ) : tasks.length === 0 ? (
        <p>No tasks found.</p>
      ) : (
        <ul className="space-y-4">
          {tasks.map((task) => (
            <li
              key={task.id}
              className="border rounded p-4 shadow-sm flex justify-between items-center"
            >
              <div className="flex-1">
                {editMode === task.id ? (
                  <input
                    value={editTitle}
                    onChange={(e) => setEditTitle(e.target.value)}
                    className="p-2 border rounded w-full"
                  />
                ) : (
                  <>
                    <h2 className="text-xl font-semibold">{task.title}</h2>
                    <p
                      className={`text-sm font-medium ${
                        task.status === 'done'
                          ? 'text-green-600'
                          : 'text-yellow-600'
                      }`}
                    >
                      {task.status.toUpperCase()}
                    </p>
                  </>
                )}
              </div>
              <div className="ml-4 flex gap-2">
                {editMode === task.id ? (
                  <button
                    onClick={() => handleUpdateTask(task.id)}
                    className="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
                  >
                    Save
                  </button>
                ) : (
                  <>
                    <button
                      onClick={() => handleToggleStatus(task)}
                      className="bg-gray-200 px-3 py-1 rounded hover:bg-gray-300"
                    >
                      Toggle
                    </button>
                    <button
                      onClick={() => handleEditTask(task)}
                      className="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
                    >
                      Edit
                    </button>
                  </>
                )}
                <button
                  onClick={() => handleDeleteTask(task.id)}
                  className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                >
                  Delete
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
