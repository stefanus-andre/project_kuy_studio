<?php

namespace App\Http\Controllers;

use App\Models\TasksModel;
use Illuminate\Http\Request;

class TasksController extends Controller
{
    public function GetAllDataTask() {
        $dataTask = TasksModel::all();
        return response()->json($dataTask);
    }

    public function GetDataTaskById($id) {
        $dataTaskById = TasksModel::find($id);
        return response()->json($dataTaskById);
    }

    public function CreateTask(Request $request) {
        $addDataTask = new TasksModel();
        $addDataTask->title = $request->title;
        $addDataTask->status = $request->status;
        $addDataTask->save();
        return response()->json($addDataTask);
    }


    public function UpdateTask(Request $request, $id) {
        $updateDataTask =  TasksModel::find($id);
        $updateDataTask->title = $request->title;
        $updateDataTask->status = $request->status;
        $updateDataTask->save();
        return response()->json($updateDataTask);
    }

    public function DeleteTask($id) {
        TasksModel::destroy($id);
        return response()->json('Task Deleted');
    }
}
