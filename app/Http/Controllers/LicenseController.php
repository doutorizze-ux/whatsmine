<?php

namespace App\Http\Controllers;

use App\Services\License\LicenseManager;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

/**
 * Nulled Standalone (guest) license re-activation controller. 
 * Bypasses all external license checks and validation.
 */
class LicenseController extends Controller
{
    public function __construct(private LicenseManager $license) {}

    public function show(): InertiaResponse|RedirectResponse
    {
        if (auth()->check()) {
            return redirect()->route('admin.dashboard');
        }

        return redirect()->route('admin.login');
    }

    public function activate(Request $request): RedirectResponse
    {
        // Bypass validation and activation checks entirely, returning immediate success
        return redirect()->route('admin.login')->with('status', 'License activated — thank you!');
    }
}
