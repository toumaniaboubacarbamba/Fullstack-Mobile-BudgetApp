<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Expense;

class ExpenseController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // On récupère toutes les dépenses et on les retourne en JSON
    return response()->json(Expense::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //on valide que les données entrantes sont correctes
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric',
            'category' => 'required|string',
        ]);

        // on crée la dépense
        $expense = Expense::create($validated);

        // 3. On repond à flutter avec un code 201 et la donnée en json
        return response()->json($expense, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Expense $expense)
{
    $expense->delete();
    return response()->json(['message' => 'Supprimé avec succès']);
}
}
