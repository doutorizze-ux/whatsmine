<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\License\LicenseManager;
use App\Services\License\Updater;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class LicenseController extends Controller
{
    public function __construct(private LicenseManager $license) {}

    public function index(): RedirectResponse
    {
        return redirect()->route('admin.dashboard');
    }

    public function checkUpdate(): JsonResponse
    {
        return response()->json(['ok' => true, 'update_available' => false, 'message' => 'You are on the latest version 1.8.0.']);
    }

    /** Download + install the available update (long-running). */
    public function applyUpdate(Updater $updater): JsonResponse
    {
        return response()->json(['ok' => true, 'message' => 'System is already up to date.']);
    }

    public function activate(Request $request): RedirectResponse
    {
        $isEnvato = $request->input('verify_type', $this->license->defaultVerifyType()) === 'envato';

        $data = $request->validate([
            'license_code' => ['required', 'string'],
            'verify_type' => ['nullable', Rule::in(LicenseManager::TYPES)],
            'client_name' => [Rule::requiredIf($isEnvato), 'nullable', 'string', 'max:255'],
        ], [], ['client_name' => 'Envato buyer name']);

        $result = $this->license->activate(
            $data['license_code'],
            (string) ($data['client_name'] ?? ''),
            $data['verify_type'] ?? null,
        );

        return back()->with($result['ok'] ? 'success' : 'error', $result['message']);
    }

    public function deactivate(): RedirectResponse
    {
        $result = $this->license->deactivate();

        return back()->with($result['ok'] ? 'success' : 'error', $result['message']);
    }
}
