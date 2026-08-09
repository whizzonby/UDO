# Figma Make to Flutter Redesign Queue

Source export: `E:/UDO APP/udo-export`

## Design System Foundation

Status: complete

- Port Figma Make color tokens, typography, cards, badges, section headers, and ring progress primitives.
- Copy export image assets into Flutter assets.
- Apply global theme and bottom navigation styling.
- Keep backend/API providers intact.

## Phase 1: Primary Shell

Status: complete

- Home: editorial wedding journal landing screen. Status: complete.
- Plan: planning workspace landing screen, right-side Planning drawer, and submodule rebuild coverage. Status: complete.
- Main navigation: floating rounded bottom nav, six global tabs. Status: complete.

## Phase 2: Core Workspaces

Status: complete

- Guests: complete for the currently mounted Flutter workspace: overview, directory, invitations command centre, guest portal / experience, communication centre, logistics, and drill-down coverage for meals, seating, check-in and insights.
- Live: complete: drawer shell, mission control, timeline, locations, weather, broadcast, team, and emergency.
- Gallery: complete for the currently mounted Flutter workspace: drawer shell, overview hero, albums/inspiration, favourites, search, guest uploads, archive, wedding story, and highlights.
- More: complete for the currently mounted Flutter workspace: account/settings hub, workspace management, AI assistant, activity, collaborators, feedback, contact support, and about.

## Phase 3: Plan Submodules

Status: complete

- Tasks. Status: complete.
- Budget. Status: complete.
- Vendors. Status: complete.
- Vision Board. Status: complete.
- Timeline. Status: complete.
- Registry. Status: complete.
- Payments. Status: complete.
- Food & Dining. Status: complete.
- Wedding Weekend. Status: complete.
- Wedding Party. Status: complete.
- Honeymoon. Status: complete.
- Insurance. Status: complete.
- Documents. Status: complete.
- Wedding Details. Status: complete.

## Phase 4: Standalone App Screens

Status: complete

- Auth and onboarding entry path: complete for the currently mounted Flutter workspace: splash, login, register, password reset, and shared onboarding shell.
- Paywall and billing entry screen: complete for the currently mounted Flutter workspace: lifetime pass hero, purchase state, restore flow, store unavailable state, and secure verification copy.
- Vision and wedding story surfaces: complete for the currently mounted Flutter workspace: day-plan hero, horizontal timeline, run-of-day simulation, PDF export card, Wedding Story chapter hero, phase cards, memory signals, loading/error/empty states.
- Memories standalone workspace: complete for the currently mounted Flutter workspace: premium hero, status metrics, redesigned tab shell, overview dashboard, Wedding Story handoff, loading/error states, and preserved speech/vow/tradition/guestbook/photo/music operations.

## Implementation Rules

- React/TypeScript export is design reference only.
- Flutter remains the production app target.
- Existing Laravel backend contracts stay unchanged unless a screen requires missing data.
- Real provider data is preferred over mock design data.
- Each feature must be formatted and checked before moving to the next feature.
