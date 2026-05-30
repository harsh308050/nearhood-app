# NEARHOOD — COMPLETE UI/UX DESIGN SPECIFICATION
## Premium Hyperlocal Social Network for India
### Light Mode Design System | 27 Screens Defined

---

# PART A: DESIGN SYSTEM FOUNDATION

## 1. Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| **Primary Blue** | `#2B5C7D` | Top bars, primary buttons, verified badges, active states, links |
| **Accent Coral** | `#F26430` | FAB, notification dots, high-energy CTAs, like/active indicators |
| **Background Grey** | `#F8F9FA` | All screen backgrounds, section separators |
| **Surface White** | `#FFFFFF` | Cards, input fields, modals, bottom sheets |
| **Charcoal Text** | `#2D3748` | Primary text, headings, usernames, titles |
| **Muted Text** | `#718096` | Timestamps, secondary labels, placeholders, captions |
| **Placeholder Text** | `#A0AEC0` | Input placeholders, disabled text, hint text |
| **Border Light** | `#E2E8F0` | Card borders, dividers, input borders, hairlines |
| **Urgent Red** | `#E53E3E` | Safety alerts, emergency tags, errors, report buttons |
| **Commerce Green** | `#38A169` | For Sale chips, FREE badges, success states, resolved banners |
| **Event Cyan** | `#3182CE` | Event category chips, event pins, info states |
| **Warning Gold** | `#D69E2E` | Star ratings, Area Lead badges, recommendations |
| **Verified Blue** | `#2B5C7D` | Verified neighbor badge background |
| **Soft Blue BG** | `#EBF4FA` | Verified badge light background, notification tint |
| **Coral Light** | `#FFF0EB` | Coral accent backgrounds, FAB glow |

## 2. Typography System

| Use Case | Font | Weight | Size | Line Height | Letter Spacing | Color |
|----------|------|--------|------|-------------|----------------|-------|
| App Name / Hero Title | Clash Display | Bold | 32px | 38px | -0.5px | `#2B5C7D` |
| Screen Titles | Clash Display | SemiBold | 24px | 30px | -0.3px | `#2D3748` |
| Section Headers | Clash Display | SemiBold | 20px | 26px | -0.2px | `#2D3748` |
| Card Titles | Satoshi | Bold | 17px | 22px | 0 | `#2D3748` |
| Body Text | Satoshi | Regular | 15px | 22px | 0 | `#2D3748` |
| Button Labels | Satoshi | Bold | 17px | 22px | 0.2px | `#FFFFFF` or `#2B5C7D` |
| Caption / Timestamp | Satoshi | Regular | 13px | 18px | 0 | `#718096` |
| Overline / Category | Satoshi | Bold | 11px | 14px | 1.5px | `#718096` uppercase |
| OTP Digits | Clash Display | Bold | 26px | 32px | 2px | `#2B5C7D` |
| Price Labels | Satoshi | Bold | 18px | 24px | 0 | `#38A169` |
| Safety Alert Content | Satoshi | Regular | 15px | 22px | 0 | `#E53E3E` |
| Empty State Title | Clash Display | SemiBold | 22px | 28px | -0.2px | `#2D3748` |
| Empty State Body | Satoshi | Regular | 15px | 22px | 0 | `#718096` |

## 3. Spacing & Layout Grid

- **Base Unit**: 4px
- **Screen Padding**: 20px horizontal (16px on very small devices)
- **Card Padding**: 16px internal
- **Card Gap**: 12px between cards
- **Section Gap**: 24px between major sections
- **Border Radius**:
  - Cards: 18px
  - Buttons: 14px
  - Input Fields: 14px
  - Chips: 100px (pill shape)
  - Avatars: 50% (circle)
  - Bottom Sheets: 24px top corners
  - Modals: 20px all corners

## 4. Component Standards

### Primary CTA Button
- Height: 56px
- Background: `#2B5C7D`
- Text: White, Satoshi Bold 17px
- Border Radius: 14px
- Shadow: `0 4px 16px rgba(43,92,125,0.30)`
- Pressed State: Background darkens to `#1E4259`, shadow reduces
- Disabled State: Background `#A0AEC0`, no shadow

### Accent CTA Button
- Same as Primary but Background: `#F26430`
- Shadow: `0 4px 16px rgba(242,100,48,0.30)`
- Pressed: `#D45220`

### Ghost Button
- Height: 56px
- Background: Transparent
- Border: 1.5px solid `#2B5C7D`
- Text: `#2B5C7D`, Satoshi Bold 17px
- Border Radius: 14px
- Pressed: Background `rgba(43,92,125,0.08)`

### Cards
- Background: `#FFFFFF`
- Border Radius: 18px
- Border: 1px solid `#E2E8F0`
- Shadow: `0 2px 8px rgba(0,0,0,0.04)`
- Padding: 16px

### Input Fields
- Height: 58px
- Background: `#FFFFFF`
- Border Radius: 14px
- Border: 1.5px solid `#E2E8F0`
- Focused Border: 1.5px solid `#2B5C7D`
- Error Border: 1.5px solid `#E53E3E`
- Text: Satoshi Regular 16px, `#2D3748`
- Placeholder: `#A0AEC0`
- Padding: 16px horizontal, 0 vertical (centered)

### Chips (Category/Filter)
- Height: 32px
- Border Radius: 100px
- Active: Background `#2B5C7D`, Text White
- Inactive: Background White, Border 1px `#E2E8F0`, Text `#718096`
- Padding: 0 16px
- Text: Satoshi SemiBold 13px

### Bottom Navigation
- Height: 80px (including safe area)
- Background: `#FFFFFF`
- Border Top: 1px solid `#E2E8F0`
- Active Icon: Filled Phosphor icon, `#2B5C7D`
- Active Indicator: 4px dot `#F26430` below icon
- Inactive Icon: Regular Phosphor icon, `#718096`
- Labels: Satoshi Regular 11px

### Avatar Sizes
- XL (Profile Hero): 96px
- L (Post Header): 44px
- M (Comment/Chat): 36px
- S (List Item): 40px
- XS (Notification): 32px

### Status Badges
- Verified Badge: 20px circle, `#2B5C7D` background, white checkmark (Phosphor Icons), positioned at avatar bottom-right
- Area Lead Badge: 18px circle, `#D69E2E` background, white star
- Unverified Warning: 8px dot, `#E53E3E`

---

# PART B: ONBOARDING SCREENS (10 Screens)

---

## SCREEN 01 — Splash Screen

**Purpose**: Brand introduction, app launch experience

### Layout Structure
- Full screen, background: `#2B5C7D` (Primary Blue)
- Content vertically and horizontally centered

### Visual Elements
1. **Logo Animation Zone** (center)
   - Logo displayed at 120px width
   - The location pin icon with house + smile
   - Subtle pulse animation on launch (scale 0.95 → 1.0, 800ms ease-out)

2. **App Name** (below logo, 24px gap)
   - "Nearhood" in Clash Display Bold, 32px, `#FFFFFF`
   - Letter spacing: -0.5px

3. **Tagline** (below name, 12px gap)
   - "Your Neighborhood, Verified." in Satoshi Regular, 16px, `rgba(255,255,255,0.80)`

4. **Bottom Loader** (bottom 80px from safe area)
   - Three dot wave loader (coral dots `#F26430`)
   - Dot size: 8px, gap: 6px
   - Animation: sequential scale 1→1.4→1, 600ms per dot

### Transitions
- Auto-advance to Login after 2.5 seconds
- Fade out: 300ms opacity 1→0
- Next screen fade in: 300ms

---

## SCREEN 02 — Login Screen

**Purpose**: Social authentication entry point

### Layout Structure
- Background: `#F8F9FA`
- Hero section: Top 45% of screen
- Auth section: Bottom 55%

### Visual Elements — Hero Section
1. **Illustration Background**
   - Soft gradient from `#2B5C7D` (top) to `#4A8BB5` (bottom)
   - Subtle abstract neighborhood illustration: simplified houses, trees, location pins in `rgba(255,255,255,0.10)` line art
   - Logo positioned top-left at 48px width with 20px padding

2. **Hero Text** (positioned bottom of hero section, 24px padding)
   - "Connect with your" — Clash Display SemiBold, 24px, White
   - "real neighbors" — Clash Display Bold, 28px, White
   - "in Bopal, Satellite, Koramangala..." — Satoshi Regular, 15px, `rgba(255,255,255,0.70)`

### Visual Elements — Auth Section
1. **Social Login Buttons** (stacked, 12px gap, 20px horizontal padding)

   **Google Button** (56px height)
   - Background: `#FFFFFF`
   - Border: 1px solid `#E2E8F0`
   - Border Radius: 14px
   - Left: Google "G" icon, 24px
   - Center: "Continue with Google" — Satoshi SemiBold, 16px, `#2D3748`
   - Shadow: `0 2px 8px rgba(0,0,0,0.04)`

   **Email Button** (same specs)
   - Envelope icon (Phosphor), 24px, `#2B5C7D`
   - "Continue with email" — Satoshi SemiBold, 16px, `#2D3748`

   **Facebook Button** (same specs)
   - Facebook "f" icon, 24px, `#1877F2`
   - "Continue with Facebook" — Satoshi SemiBold, 16px, `#2D3748`

2. **Terms Text** (below buttons, 20px gap)
   - "By continuing, you agree to our" — Satoshi Regular, 13px, `#718096`
   - "Privacy Policy" and "Member Agreement" — Satoshi SemiBold, 13px, `#2B5C7D` (tappable links)

3. **Language Selector** (bottom, 16px from safe area)
   - Globe icon (Phosphor), 16px, `#718096`
   - "EN" — Satoshi SemiBold, 14px, `#2D3748`
   - Chevron down icon, 12px
   - Right side: "Have an invite code?" — Satoshi SemiBold, 14px, `#2B5C7D`

### Interactions
- Button press: scale 0.98, background darkens slightly, 100ms
- Loading state: button shows 20px WaveDots loader, text hidden, opacity 0.7

---

## SCREEN 03 — Email Signup

**Purpose**: Email/password registration

### Layout Structure
- Background: `#F8F9FA`
- Top bar with back arrow
- Form centered with 20px horizontal padding

### Visual Elements
1. **Top Navigation**
   - Back arrow (Phosphor), 24px, `#2D3748`, left aligned, 20px padding
   - Screen is modal-style slide from right

2. **Header** (top 24px below nav)
   - "Create your account" — Clash Display SemiBold, 24px, `#2D3748`
   - "Join your neighborhood community" — Satoshi Regular, 15px, `#718096`

3. **Form Fields** (stacked, 16px gap)

   **Full Name Input**
   - Label: "Full name" — Satoshi SemiBold, 14px, `#2D3748`, 8px below
   - Input field (58px, standard input styling)
   - Placeholder: "Enter your full name"
   - Real-name policy note below: "Neighbors use real names on Nearhood" — Satoshi Regular, 12px, `#718096`

   **Email Input**
   - Label: "Email address"
   - Placeholder: "yourname@email.com"
   - Keyboard: email type

   **Password Input**
   - Label: "Password"
   - Placeholder: "Min. 8 characters"
   - Right side: Eye icon (Phosphor) for toggle visibility
   - **Strength Indicator** (below input, 8px gap):
     - 4 segment bars, 40px wide each, 4px height, 4px gap
     - Empty: `#E2E8F0`
     - Weak (1 bar): `#E53E3E`
     - Fair (2 bars): `#D69E2E`
     - Good (3 bars): `#3182CE`
     - Strong (4 bars): `#38A169`
     - Label: "Password strength" — Satoshi Regular, 12px, `#718096`

4. **Primary CTA** (below form, 24px gap)
   - "Continue" — Primary CTA button
   - Disabled until all fields valid

5. **Switch to Login** (bottom, centered)
   - "Already have an account?" — Satoshi Regular, 14px, `#718096`
   - "Log in" — Satoshi SemiBold, 14px, `#2B5C7D`

### Interactions
- Input focus: border transitions to `#2B5C7D`, 200ms
- Password strength updates in real-time as user types
- Continue button enables when: name ≥ 2 chars, valid email, password ≥ 8 chars

---

## SCREEN 04 — Location Selection

**Purpose**: Country and locality initial selection

### Layout Structure
- Background: `#F8F9FA`
- Progress indicator at top
- Hero illustration + form

### Visual Elements
1. **Progress Bar** (top, 16px from safe area)
   - 5 segments representing onboarding steps
   - Current step (1/5) filled: `#2B5C7D`
   - Future steps: `#E2E8F0`
   - Height: 4px, gap: 4px, border radius: 2px

2. **Hero Illustration** (top 30% of screen)
   - Flat illustration of Indian neighborhood map
   - Soft blue gradient background `#EBF4FA`
   - Stylized map with location pins, houses, streets in line art `#2B5C7D`
   - Subtle animated floating pins (gentle up-down, 2s loop)

3. **Header** (below illustration, 24px padding)
   - "Where do you live?" — Clash Display SemiBold, 24px, `#2D3748`
   - "We'll connect you with verified neighbors nearby" — Satoshi Regular, 15px, `#718096`

4. **Country Selector** (20px padding horizontal)
   - Label: "Country" — Satoshi SemiBold, 14px, `#2D3748`
   - Dropdown field (58px, standard input styling)
   - Left: India flag icon, 24px
   - Text: "India" — Satoshi Regular, 16px, `#2D3748`
   - Right: Chevron down, 16px, `#718096`
   - Disabled state (only India available initially)

5. **Locality Search Field** (16px below country)
   - Label: "Your locality or area"
   - Input with search icon (Phosphor magnifying glass, 20px, `#718096`) left aligned inside
   - Placeholder: "e.g., Bopal, Koramangala, Satellite"
   - Right: GPS icon (Phosphor), 20px, `#2B5C7D` — "Use current location"
   - Tapping opens Screen 05 (Area Search)

6. **Popular Areas** (below input, 20px gap)
   - Label: "Popular in Ahmedabad" — Satoshi SemiBold, 14px, `#718096`
   - Horizontal scroll of chips: "Bopal", "Satellite", "Prahlad Nagar", "Thaltej", "Vastrapur"
   - Inactive chip styling
   - Gap: 8px

7. **Primary CTA** (bottom, 24px from safe area)
   - "Continue" — Primary CTA, disabled until locality selected

---

## SCREEN 05 — Area Search

**Purpose**: Full-screen locality picker with GPS and search

### Layout Structure
- Background: `#FFFFFF`
- Modal presentation (slides up from bottom, covers full screen)
- Search bar fixed at top
- Results scroll below

### Visual Elements
1. **Top Bar**
   - Background: `#FFFFFF`
   - Border bottom: 1px solid `#E2E8F0`
   - Height: 60px + safe area
   - Left: Close/X icon (Phosphor), 24px, `#2D3748`
   - Center: "Select your area" — Satoshi SemiBold, 17px, `#2D3748`

2. **Search Bar** (fixed below top bar, 16px padding)
   - Background: `#F8F9FA`
   - Border Radius: 14px
   - Height: 48px
   - Left: Search icon, 20px, `#718096`
   - Placeholder: "Search localities..." — Satoshi Regular, 16px, `#A0AEC0`
   - Right: GPS icon button (36px circle, `#EBF4FA` background, `#2B5C7D` icon)
   - Clear button appears when text entered (X icon, `#718096`)

3. **Current Location Section** (below search, 16px padding)
   - "Use your current location" — Satoshi SemiBold, 15px, `#2B5C7D`
   - Subtext: "We'll detect your area automatically" — Satoshi Regular, 13px, `#718096`
   - Left: Location pin icon in circle (40px, `#EBF4FA` bg, `#2B5C7D` icon)
   - Right: Chevron right, 16px, `#718096`
   - Full width tappable row

4. **Search Results / Popular Areas**
   - Section header: "Popular areas near you" — Satoshi SemiBold, 14px, `#718096`, uppercase, letter-spacing 1px
   - List of locality items:
     - Each item: 56px height, 20px horizontal padding
     - Left: Location pin icon, 20px, `#718096`
     - Middle: Locality name ("Bopal") — Satoshi SemiBold, 16px, `#2D3748`
     - Subtext: "Ahmedabad, Gujarat" — Satoshi Regular, 13px, `#718096`
     - Right: Chevron right, 16px, `#E2E8F0`
     - Divider: 1px `#E2E8F0` bottom (except last)
     - Selected state: background `#EBF4FA`, left border 3px `#2B5C7D`

5. **Search Active State**
   - As user types, results filter in real-time
   - "No results" state: Illustration + "No areas found" + "Try a different search term"

### Interactions
- Search bar focused immediately on open
- GPS button triggers location detection with loading spinner
- Item selection: brief highlight `#EBF4FA`, then dismiss modal returning selected locality to Screen 04

---

## SCREEN 06 — Address Details

**Purpose**: Collect precise address within locality

### Layout Structure
- Background: `#F8F9FA`
- Progress indicator: 2/5
- Form with pre-filled locality info

### Visual Elements
1. **Progress Bar** (2/5 filled)

2. **Header** (24px below progress)
   - "Your address details" — Clash Display SemiBold, 24px, `#2D3748`
   - "Only your locality name is visible to neighbors" — Satoshi Regular, 14px, `#718096`
   - Small info icon (Phosphor) next to text

3. **Pre-filled Location Card** (16px below header)
   - Card styling (white, 18px radius, 1px border `#E2E8F0`)
   - Padding: 16px
   - Left: Map pin icon, 24px, `#2B5C7D`
   - "Bopal, Ahmedabad" — Satoshi SemiBold, 16px, `#2D3748`
   - "Gujarat, India" — Satoshi Regular, 14px, `#718096`
   - Right: Edit icon (pencil), 16px, `#2B5C7D` (goes back to area search)

4. **Form Fields** (16px gap between fields)

   **Pincode Input**
   - Label: "PIN code" — Satoshi SemiBold, 14px
   - Input placeholder: "380058"
   - Keyboard: numeric
   - 6 character limit

   **Flat/Building Input**
   - Label: "Flat / Building / Society"
   - Placeholder: "e.g., Flat 402, Shyamal Row House"

   **Street/Landmark Input**
   - Label: "Street or landmark"
   - Placeholder: "e.g., Near Bopal Gram Panchayat"

5. **Privacy Note** (below form, 16px gap)
   - Shield icon (Phosphor), 16px, `#38A169`
   - "Your exact address is never shown to other residents" — Satoshi Regular, 13px, `#718096`

6. **Primary CTA**
   - "Continue" — Primary CTA
   - Disabled until pincode (6 digits) entered

---

## SCREEN 07 — Mobile Number Entry

**Purpose**: Phone number collection for OTP verification

### Layout Structure
- Background: `#2B5C7D` (Primary Blue full bleed)
- White card floating in center-bottom area
- Hero text at top

### Visual Elements
1. **Hero Section** (top 35%, blue background)
   - Large phone icon illustration (Phosphor "DeviceMobile"), 80px, `rgba(255,255,255,0.20)`
   - "Verify your number" — Clash Display SemiBold, 24px, `#FFFFFF`
   - "We'll send a 6-digit OTP to confirm it's you" — Satoshi Regular, 15px, `rgba(255,255,255,0.80)`

2. **Input Card** (bottom 65%, white, top radius 24px)
   - Background: `#FFFFFF`
   - Top corners: 24px radius
   - Padding: 24px 20px

   **Phone Input Field**
   - Label: "Mobile number" — Satoshi SemiBold, 14px, `#2D3748`
   - Field height: 58px
   - Left section: Country code selector
     - "+91" — Satoshi SemiBold, 16px, `#2D3748`
     - India flag, 20px
     - Chevron down, 12px, `#718096`
     - Vertical divider: 1px `#E2E8F0` after 80px
   - Right section: Phone number input
     - Placeholder: "98765 43210"
     - Satoshi Regular, 18px, `#2D3748`
     - Letter spacing: 1px for readability
     - Keyboard: numeric
     - 10 digit limit

   **Info Note**
   - Lock icon (Phosphor), 16px, `#718096`
   - "One number = one account. Prevents fake profiles." — Satoshi Regular, 13px, `#718096`

3. **Primary CTA** (within white card, 24px below input)
   - "Send OTP" — Primary CTA button
   - Disabled until 10 digits entered
   - Loading state: WaveDots loader, coral color

4. **Skip Option** (bottom of card, 16px gap)
   - "Skip for now" — Satoshi Regular, 14px, `#718096`
   - Ghost button styling, no border
   - Leads to limited read-only experience

### Interactions
- Phone input auto-formats with spaces: 98765 43210
- "Send OTP" triggers SMS with 30s countdown before resend available
- Success: auto-advance to OTP screen with slide transition

---

## SCREEN 08 — OTP Verification

**Purpose**: 6-digit OTP entry

### Layout Structure
- Background: `#F8F9FA`
- Centered content
- Back button top-left

### Visual Elements
1. **Top Navigation**
   - Back arrow, 24px, `#2D3748`
   - Screen slides in from right

2. **Header** (centered, 40px from top)
   - "Enter OTP" — Clash Display SemiBold, 24px, `#2D3748`
   - "Sent to +91 98765 43210" — Satoshi Regular, 15px, `#718096`
   - Edit icon (pencil) next to number — allows changing number

3. **OTP Input Boxes** (centered, 32px below header)
   - 6 individual boxes in a row
   - Each box: 48px × 56px
   - Background: `#FFFFFF`
   - Border: 1.5px solid `#E2E8F0`
   - Border Radius: 14px
   - Text: Clash Display Bold, 26px, `#2B5C7D`, centered
   - Gap between boxes: 10px

   **Active State** (current input box):
   - Border: 1.5px solid `#2B5C7D`
   - Shadow: `0 0 0 4px rgba(43,92,125,0.15)`
   - Subtle scale: 1.02

   **Filled State**:
   - Background: `#EBF4FA`
   - Border: 1.5px solid `#2B5C7D`

4. **Auto-advance**
   - Typing in one box automatically focuses next
   - Backspace on empty box moves to previous

5. **Resend Section** (below OTP, 24px gap, centered)
   - Timer: "Resend in 00:30" — Satoshi Regular, 14px, `#718096`
   - Countdown format, coral color `#F26430` for seconds
   - When timer expires: "Didn't receive it?" — Satoshi Regular, 14px, `#718096`
   - "Resend OTP" — Satoshi SemiBold, 14px, `#2B5C7D` (tappable link)
   - "Get via call instead" — Satoshi Regular, 14px, `#2B5C7D` (secondary option)

6. **Success Animation**
   - On correct OTP: boxes fill green `#38A169` sequentially (100ms each)
   - Checkmark icon appears in center
   - Auto-advance to Notification Permission after 500ms

7. **Error State**
   - On wrong OTP: boxes shake horizontally (300ms)
   - Border turns `#E53E3E`
   - "Invalid OTP. Please try again." — Satoshi Regular, 14px, `#E53E3E`
   - Clears after 2s

---

## SCREEN 09 — Notification Permission

**Purpose**: Explain and request push notification access

### Layout Structure
- Background: `#F8F9FA`
- Illustration + benefits list + CTAs
- Progress: 4/5

### Visual Elements
1. **Progress Bar** (4/5 filled)

2. **Illustration** (top 30%)
   - Background: `#EBF4FA`
   - Animated notification bell illustration (Phosphor "Bell"), 80px, `#2B5C7D`
   - Subtle ring animation (scale pulse)
   - Small notification badges floating around: "Safety Alert", "Reply", "Event"
   - Badges: pill shape, coral `#F26430` background, white text, Satoshi Bold 11px

3. **Header** (24px below illustration)
   - "Stay in the loop" — Clash Display SemiBold, 24px, `#2D3748`
   - "Get notified about what matters in your neighborhood" — Satoshi Regular, 15px, `#718096`

4. **Benefits List** (20px below header, 20px horizontal padding)
   Three benefit cards stacked (12px gap):

   **Card 1: Safety Alerts**
   - Icon: Shield icon (Phosphor), 24px, `#E53E3E`, in 40px circle `#FFF5F5`
   - Title: "Safety Alerts" — Satoshi SemiBold, 16px, `#2D3748`
   - Subtitle: "Urgent neighborhood warnings" — Satoshi Regular, 14px, `#718096`

   **Card 2: Replies**
   - Icon: Chat bubble (Phosphor), 24px, `#2B5C7D`, in 40px circle `#EBF4FA`
   - Title: "Replies to your posts" — Satoshi SemiBold, 16px
   - Subtitle: "Know when neighbors respond" — Satoshi Regular, 14px

   **Card 3: Events**
   - Icon: Calendar (Phosphor), 24px, `#38A169`, in 40px circle `#F0FFF4`
   - Title: "Local events" — Satoshi SemiBold, 16px
   - Subtitle: "Don't miss community gatherings" — Satoshi Regular, 14px

5. **CTA Section** (bottom, 24px from safe area)
   - "Turn on notifications" — Accent CTA button (`#F26430`)
   - "Maybe later" — Ghost button, below, 12px gap
   - "Skip" — Satoshi Regular, 14px, `#718096`, text only, below ghost button

### Interactions
- "Turn on notifications" triggers native iOS/Android permission dialog
- "Maybe later" stores preference, allows re-prompt later
- "Skip" proceeds without notifications

---

## SCREEN 10 — Community Rules

**Purpose**: Final onboarding step — agree to community guidelines

### Layout Structure
- Background: `#F8F9FA`
- Progress: 5/5 (all filled)
- Four rule cards + agreement CTA

### Visual Elements
1. **Progress Bar** (5/5, all `#2B5C7D`)

2. **Header** (24px below progress)
   - "Community Rules" — Clash Display SemiBold, 24px, `#2D3748`
   - "Nearhood works when everyone follows these" — Satoshi Regular, 15px, `#718096`

3. **Rule Cards** (stacked, 12px gap, 20px horizontal padding)
   Each card: white, 18px radius, 1px border `#E2E8F0`, padding 20px

   **Rule 1: Be Helpful**
   - Left: Number "1" in 32px circle, `#2B5C7D` bg, white text, Clash Display Bold 16px
   - Title: "Be Helpful" — Satoshi Bold, 17px, `#2D3748`
   - Body: "Share useful, accurate information. Help your neighbors, not confuse them." — Satoshi Regular, 14px, `#718096`

   **Rule 2: Lead with Respect**
   - Number "2" circle
   - Title: "Lead with Respect"
   - Body: "Treat every neighbor with dignity regardless of background, opinion, or lifestyle."

   **Rule 3: Do Not Harm**
   - Number "3" circle
   - Title: "Do Not Harm"
   - Body: "Never post content that threatens, endangers, or harms others in the community."

   **Rule 4: All Are Welcome**
   - Number "4" circle
   - Title: "All Are Welcome"
   - Body: "Nearhood is for everyone. No discrimination of any kind is tolerated."

4. **Agreement Checkbox** (below rules, 24px gap)
   - Custom checkbox: 24px square, 6px radius, border 1.5px `#E2E8F0`
   - Checked state: `#2B5C7D` fill, white checkmark (Phosphor)
   - Label: "I agree to follow these rules" — Satoshi SemiBold, 15px, `#2D3748`
   - Required to enable CTA

5. **Primary CTA** (bottom, 24px from safe area)
   - "Join Nearhood" — Primary CTA button
   - Disabled until checkbox checked
   - On tap: brief confetti animation (coral and blue particles, 1s)
   - Transitions to Home Feed with fade

---

# PART C: MAIN APP SCREENS (17 Screens)

---

## SCREEN 11 — Home Feed

**Purpose**: Main neighborhood feed — the heart of Nearhood

### Layout Structure
- Background: `#F8F9FA`
- Top App Bar (fixed)
- Verification Banner (if needed)
- Category Chips (horizontal scroll, fixed below banner)
- Feed List (scrollable)
- Floating Action Button
- Bottom Navigation (fixed)

### Visual Elements

#### 1. Top App Bar (64px + safe area)
- Background: `#FFFFFF`
- Border bottom: 1px solid `#E2E8F0`
- Left: 
  - Location selector: "Bopal" — Satoshi SemiBold, 17px, `#2D3748`
  - Verified checkmark icon (if verified), 16px, `#2B5C7D`
  - Chevron down, 14px, `#718096`
  - Tapping opens locality switcher bottom sheet
- Center: Nearhood wordmark (small, 80px width) — OR hidden, location centered
- Right:
  - Notification bell icon (Phosphor), 24px, `#2D3748`
  - Badge: if unread, 8px coral `#F26430` dot top-right of icon
  - Chat icon (Phosphor), 24px, `#2D3748`, 16px gap from bell
  - Avatar: 32px circle, user's initial (e.g., "H"), `#2B5C7D` background, white text
  - Tapping avatar opens side drawer

#### 2. Verification Banner (if user unverified)
- Background: `#EBF4FA`
- Padding: 12px 20px
- Left: Info icon (Phosphor), 20px, `#2B5C7D`
- Text: "You're almost there! To finish joining your neighborhood, verify your area." — Satoshi Regular, 14px, `#2B5C7D`
- Right: "Verify now" — Satoshi SemiBold, 14px, `#2B5C7D`, underlined
- Dismissible: X icon rightmost, 16px, `#718096`

#### 3. "What's Happening" Composer Bar (below banner)
- Background: `#FFFFFF`
- Height: 64px
- Padding: 12px 20px
- Left: User avatar, 40px circle
- Center: "What's happening, neighbor?" — Satoshi Regular, 15px, `#A0AEC0`
- Right: Photo icon (Phosphor), 24px, `#718096` + "Post" button (coral `#F26430` pill, 36px height, white text Satoshi Bold 13px)
- Full row tappable → opens Compose Post

#### 4. Category Chips (horizontal scroll)
- Background: `#F8F9FA`
- Padding: 12px 20px
- Height: 56px
- Chips: "All", "General", "Question", "Safety Alert", "For Sale", "Event", "Lost & Found", "Recommendation"
- "All" active by default (filled `#2B5C7D`)
- Others inactive (white, border `#E2E8F0`)
- Gap: 8px
- Scroll indicator: subtle fade on right edge

#### 5. Feed Content (scrollable)
- Padding: 0 20px
- Gap between posts: 12px

**Post Card Structure**:
- Card styling (white, 18px radius, 1px border `#E2E8F0`)
- Padding: 16px

**Post Header**:
- Height: 48px
- Left: Avatar 40px circle + verification badge if applicable
- Middle: 
  - Name: "P. G." — Satoshi SemiBold, 15px, `#2D3748`
  - Meta: "Appleton, WI · 24m · 🌐" — Satoshi Regular, 13px, `#718096`
- Right: More options icon (3 dots), 20px, `#718096`

**Post Body**:
- Text: "Need tree removal you can trust? References and fully insured. 😊" — Satoshi Regular, 15px, `#2D3748`, line-height 22px
- Max 5 lines, then "...see more" — Satoshi SemiBold, 15px, `#2B5C7D`

**Business Card (if attached)**:
- Background: `#F8F9FA`
- Border radius: 12px
- Padding: 12px
- Left: Shop icon (Phosphor), 24px, `#38A169`, in 40px circle `#F0FFF4`
- Middle: 
  - "Motivated Manny lawn care & Tree servi..." — Satoshi SemiBold, 15px, `#2D3748`
  - "2373 Fiesta Court, Neenah, WI" — Satoshi Regular, 13px, `#718096`
- Right: "Fave" with heart icon, 13px, `#718096`
- Below: Avatar stack (J, C, K) + "29" in green pill `#38A169`

**Post Actions Row**:
- Height: 44px
- Left: Heart icon (Phosphor), 24px, `#718096` + count
- Center-left: Comment icon, 24px, `#718096` + count
- Center: Share icon, 24px, `#718096`
- Active states: icon fills with color (heart → `#E53E3E`, comment → `#2B5C7D`)

**Sponsored Post**:
- "Sponsored" label — Satoshi Bold, 11px, `#718096`, uppercase, letter-spacing 1px
- Brand icon (e.g., T-Mobile), 40px square, 8px radius
- "T-Mobile 5G Home Internet" — Satoshi SemiBold, 15px
- "Sponsored" sublabel
- Body text
- Image if provided

#### 6. Floating Action Button (FAB)
- Position: bottom-right, 24px from right, 100px above bottom nav
- Size: 56px circle
- Background: `#F26430` (Accent Coral)
- Icon: Pencil/edit (Phosphor), 24px, white
- Shadow: `0 4px 16px rgba(242,100,48,0.40)`
- Pressed: scale 0.95, background `#D45220`

#### 7. Bottom Navigation
- Height: 80px (including safe area)
- Background: `#FFFFFF`
- Border top: 1px solid `#E2E8F0`
- 4 tabs:
  1. **Home**: House icon (Phosphor filled), label "Home" — active: `#2B5C7D` + coral dot indicator
  2. **Search**: Magnifying glass icon, label "Search" — inactive: `#718096`
  3. **For Sale**: Shopping bag icon, label "For Sale" — inactive: `#718096`
  4. **Post**: Pencil in square icon (this is the tab, NOT the FAB) — wait, from screenshots it's: Home, Search, For Sale, and a green Post button

  Actually from screenshots: The bottom nav shows Home, Search, For Sale as text+icon tabs, and a separate green circular "Post" button on the right side (not a tab).

  Let's refine:
  - 3 tabs: Home, Search, For Sale
  - Active tab: filled icon `#2B5C7D`, label `#2B5C7D`, coral dot below icon (4px)
  - Inactive: regular icon `#718096`, label `#718096`
  - Right side: Green circular "Post" button (separate from nav)

---

## SCREEN 12 — Post Detail

**Purpose**: Full post view with comments thread

### Layout Structure
- Background: `#F8F9FA`
- Scrollable content
- Sticky comment input at bottom

### Visual Elements

#### 1. Top App Bar
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Left: Back arrow, 24px, `#2D3748`
- Center: "Post" — Satoshi SemiBold, 17px, `#2D3748`
- Right: Share icon + More options (3 dots)

#### 2. Post Card (full width, no border, flat)
- Same structure as feed post but expanded
- Body text: full content, no truncation
- Image carousel if present:
  - Height: 280px
  - Border radius: 12px
  - Page dots: 6px circles, active `#2B5C7D`, inactive `#E2E8F0`
  - Swipeable

#### 3. Engagement Stats
- Padding: 16px 20px
- "12 likes · 4 comments" — Satoshi Regular, 14px, `#718096`
- Divider: 1px `#E2E8F0`

#### 4. Action Bar
- Height: 48px
- Like, Comment, Share buttons equally spaced
- Active states with color

#### 5. Comments Section
- Header: "Comments (4)" — Satoshi SemiBold, 17px, `#2D3748`, 20px padding
- Comment cards stacked:
  - Left: Avatar 36px
  - Top: Name — Satoshi SemiBold, 14px + timestamp — Satoshi Regular, 12px, `#718096`
  - Body: Comment text — Satoshi Regular, 15px, `#2D3748`
  - Actions: Like (heart, 14px), Reply — Satoshi SemiBold, 13px, `#718096`
  - Nested replies: indented 44px, left border 2px `#E2E8F0`

#### 6. Sticky Comment Input
- Position: bottom, above keyboard
- Background: `#FFFFFF`
- Border top: 1px `#E2E8F0`
- Height: 56px + safe area
- Left: User avatar 32px
- Center: Input field "Add a comment..." — Satoshi Regular, 15px
- Right: Send button (paper plane icon), 24px, `#2B5C7D`, disabled until text entered

---

## SCREEN 13 — Category Picker

**Purpose**: Select post category before composing

### Layout Structure
- Background: `#F8F9FA`
- Modal bottom sheet (slides up)
- Grid of category tiles

### Visual Elements
1. **Sheet Handle**
   - Top center: 36px × 4px bar, `#E2E8F0`, 100px radius

2. **Header**
   - "What are you posting?" — Clash Display SemiBold, 22px, `#2D3748`
   - "Choose a category" — Satoshi Regular, 15px, `#718096`
   - Padding: 24px 20px 16px

3. **Category Grid**
   - 2 columns
   - Gap: 12px
   - Padding: 0 20px

   Each tile (aspect ratio ~1:1.1):
   - Background: `#FFFFFF`
   - Border: 1px `#E2E8F0`
   - Border radius: 18px
   - Padding: 20px
   - Center: Category icon (Phosphor), 32px
   - Below: Category name — Satoshi SemiBold, 15px, `#2D3748`
   - Below: Brief description — Satoshi Regular, 12px, `#718096`

   **Categories**:
   1. **General** — Chat icon, `#2B5C7D` — "Anything neighborhood-related"
   2. **Question** — Question mark icon, `#3182CE` — "Ask neighbors for help"
   3. **Safety Alert** — Shield icon, `#E53E3E` — "Urgent warnings"
   4. **Lost & Found** — Search icon, `#D69E2E` — "Pets, items, people"
   5. **For Sale** — Tag icon, `#38A169` — "Buy and sell locally"
   6. **Event** — Calendar icon, `#3182CE` — "Community gatherings"
   7. **Recommendation** — Star icon, `#D69E2E` — "Local business reviews"

4. **Selected State**
   - Border: 2px solid category color
   - Background: `rgba(color, 0.05)`
   - Checkmark icon top-right

5. **Cancel Button**
   - Below grid, 24px gap
   - "Cancel" — Ghost button

---

## SCREEN 14 — Compose Post

**Purpose**: Create and publish a neighborhood post

### Layout Structure
- Background: `#F8F9FA`
- Top bar fixed
- Scrollable composer area
- Toolbar fixed above keyboard

### Visual Elements

#### 1. Top App Bar
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Left: Close/X icon, 24px, `#2D3748` + "Back" label
- Center: Category label — "New Post" or category name — Satoshi SemiBold, 17px
- Right: "Post" button — Satoshi Bold, 16px, `#2B5C7D`, disabled until content entered

#### 2. Composer Area
- Padding: 20px
- Left: User avatar 40px
- Right: Text input
  - "What's happening, neighbor?" — Satoshi Regular, 18px, `#2D3748`
  - Placeholder: `#A0AEC0`
  - Min height: 120px
  - Auto-expands up to 400px

#### 3. Photo Attachments
- Horizontal scroll of selected images
- Each thumbnail: 80px × 80px, 12px radius
- Remove button: 20px circle, `rgba(0,0,0,0.60)` bg, X icon white
- Add more button: 80px × 80px, dashed border 2px `#E2E8F0`, plus icon `#718096`

#### 4. Visibility Selector
- Card: white, 18px radius, 1px border `#E2E8F0`
- Padding: 16px
- Label: "Who can see this?" — Satoshi SemiBold, 14px
- Radio options:
  1. "My Area Only" — Selected by default, radio filled `#2B5C7D`
  2. "My Area + Nearby" — Radio empty
  3. "Whole City" — Radio empty
- Each option: 44px height, icon (map pin with radius), title, description

#### 5. Bottom Toolbar
- Height: 48px
- Background: `#FFFFFF`
- Border top: 1px `#E2E8F0`
- Icons: Photo (image), Camera, Poll, Location
- Each: 24px icon, `#718096`, 48px touch target

---

## SCREEN 15 — Explore (List View)

**Purpose**: Discovery hub for alerts, events, businesses, marketplace

### Layout Structure
- Background: `#F8F9FA`
- Top bar with toggle (List/Map)
- Scrollable sections

### Visual Elements

#### 1. Top App Bar
- Background: `#FFFFFF`
- "Explore" — Clash Display SemiBold, 22px
- Right: Map toggle icon (Phosphor "MapTrifold"), 24px, `#2D3748` → switches to Map view

#### 2. Search Bar
- Padding: 12px 20px
- Standard search input styling
- Placeholder: "Search posts, neighbors, businesses..."

#### 3. Sections (vertical stack, 24px gap between sections)

**Section: Safety Alerts**
- Header: "Safety Alerts" — Satoshi SemiBold, 17px + "See all" link `#2B5C7D`
- If active alerts: Red-accent card
  - Background: `#FFF5F5`
  - Border: 1px `#E53E3E` (left border 3px)
  - Icon: Shield, `#E53E3E`
  - Title: Alert title
  - Time: "2h ago"
  - "Urgent" badge: pill, `#E53E3E` bg, white text
- If none: "All quiet in the neighborhood" — Satoshi Regular, 14px, `#718096`

**Section: Upcoming Events**
- Header + "See all"
- Horizontal scroll of event cards
- Event card: 200px width, white, 18px radius
  - Top: Date badge (e.g., "JUN 15"), `#3182CE` bg, white text
  - Image: 120px height
  - Title: Event name — Satoshi SemiBold, 15px
  - Location: "Bopal Community Hall" — Satoshi Regular, 13px

**Section: Trending Discussions**
- List of 3 hot posts
- Each: Title + comment count + "Hot" badge (coral `#F26430`)

**Section: Marketplace Highlights**
- "Newest listings near you" header
- 2-column grid of listing thumbnails
- Each: Image, title, price (green), distance

**Section: Recommended Businesses**
- Horizontal scroll
- Business card: 160px width
  - Logo/image: 48px
  - Name, category, rating (stars gold), "Recommended by neighbors" badge if applicable

---

## SCREEN 16 — Explore (Map View)

**Purpose**: Geographic discovery with map pins

### Layout Structure
- Full screen map
- Floating UI overlays
- Draggable bottom sheet for details

### Visual Elements

#### 1. Map Background
- Google Maps styled with Nearhood colors
- Custom map style: muted colors, highlighted locality polygon in `#2B5C7D` at 15% opacity
- User location: blue dot with accuracy ring

#### 2. Floating Chips (top, below status bar)
- Horizontal scroll
- Chips: "All", "Safety", "Events", "For Sale", "Businesses"
- Active: filled `#2B5C7D`
- Each chip has category-colored dot (6px) left of text

#### 3. Map Pins
- Custom pins based on category:
  - General: `#2B5C7D` pin
  - Safety: `#E53E3E` pin with pulse animation
  - Event: `#3182CE` pin with calendar icon
  - For Sale: `#38A169` pin with tag icon
  - Business: `#D69E2E` pin with star icon
- Pin size: 40px × 48px
- Selected pin: scales to 1.2, shows callout

#### 4. Callout Bubble
- Background: `#FFFFFF`
- Border radius: 14px
- Shadow: `0 4px 16px rgba(0,0,0,0.15)`
- Pointer: 12px triangle at bottom
- Content: Post title (truncated), author avatar+name, category icon

#### 5. Bottom Sheet (draggable)
- Initial height: 180px (peek)
- Max height: 70% of screen
- Handle: 36px × 4px bar top center
- Content: List of visible-area posts sorted by distance
- Each item: compact post row (avatar, title, distance, category color indicator)

#### 6. Recenter Button
- Bottom-right above sheet
- 48px circle, white, shadow
- Target icon (Phosphor), 24px, `#2B5C7D`

---

## SCREEN 17 — Notifications

**Purpose**: Grouped notification list

### Layout Structure
- Background: `#F8F9FA`
- Top bar with filter tabs
- Grouped list

### Visual Elements

#### 1. Top App Bar
- "Notifications" — Clash Display SemiBold, 22px
- Right: "Mark all read" — Satoshi Regular, 14px, `#2B5C7D`

#### 2. Filter Tabs
- Height: 44px
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Tabs: "All", "Neighborhood", "My activity", "Alerts"
- Active: text `#2D3748`, bottom border 2px `#2B5C7D`
- Inactive: text `#718096`
- Badge counts on tabs if applicable (coral dot with number)

#### 3. Notification Groups
- Today, Yesterday, Earlier — section headers
- Header: Satoshi SemiBold, 13px, `#718096`, uppercase, letter-spacing 1px, 12px padding

**Notification Row** (72px height, 20px horizontal padding):
- Left: 
  - Avatar 40px OR category icon in 40px circle
  - Icon background color matches notification type:
    - Reply: `#EBF4FA`, icon `#2B5C7D`
    - Like: `#FFF0EB`, icon `#F26430`
    - Safety: `#FFF5F5`, icon `#E53E3E`
    - Event: `#EBF8FF`, icon `#3182CE`
    - System: `#F8F9FA`, icon `#718096`
- Middle:
  - Content: "P. G. replied to your post" — Satoshi Regular, 15px, `#2D3748`
  - Preview: "Thanks for the recommendation!" — Satoshi Regular, 14px, `#718096`, truncated
  - Time: "2h ago" — Satoshi Regular, 12px, `#718096`
- Right:
  - Unread indicator: 8px `#F26430` dot
  - Or thumbnail preview if post has image (40px square, 8px radius)

**Empty State**:
- Illustration: Bell with Zzz (Phosphor style), 80px, `#E2E8F0`
- "No updates" — Clash Display SemiBold, 22px
- "All quiet in the neighborhood." — Satoshi Regular, 15px

---

## SCREEN 18 — Inbox

**Purpose**: Conversation list

### Layout Structure
- Background: `#F8F9FA`
- List of conversation threads

### Visual Elements

#### 1. Top App Bar
- "Messages" — Clash Display SemiBold, 22px
- Right: New message icon (Phosphor "PaperPlaneTilt"), 24px

#### 2. Search Bar
- "Search messages..." — standard search styling

#### 3. Conversation List
- Each row: 76px height, 20px horizontal padding
- Left: 
  - Avatar 48px circle
  - Online indicator: 14px circle, `#38A169` border 2px white, positioned bottom-right of avatar
  - Area Lead badge if applicable: small star icon overlay
- Middle:
  - Name: "Harsh P." — Satoshi SemiBold, 16px, `#2D3748`
  - Preview: "Is the sofa still available?" — Satoshi Regular, 14px, `#718096`, truncated
  - If unread: preview text `#2D3748`, Satoshi SemiBold
- Right:
  - Time: "10m" — Satoshi Regular, 12px, `#718096`
  - Unread badge: 20px circle, `#F26430`, white text Satoshi Bold 12px, if unread count > 0
  - Mute icon if conversation muted

**Swipe Actions** (right swipe):
- Mute: Grey background, bell icon
- Delete: Red background `#E53E3E`, trash icon

**Empty State**:
- Chat bubbles illustration, 80px, `#E2E8F0`
- "No messages yet" — Clash Display SemiBold, 22px
- "Start a conversation with a verified neighbor" — Satoshi Regular, 15px
- "Find neighbors" button — Primary CTA

---

## SCREEN 19 — Chat

**Purpose**: Direct messaging between neighbors

### Layout Structure
- Background: `#F8F9FA`
- Top bar fixed
- Messages scrollable
- Input bar fixed bottom

### Visual Elements

#### 1. Top App Bar
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Left: Back arrow + Avatar 32px + Name "Harsh P." + "Bopal" subtitle
- Right: Phone icon (if applicable) + More options (3 dots)
- If other user unverified: subtle "Unverified" label in `#E53E3E`

#### 2. Warning Banner (if unverified)
- Background: `#FFF5F5`
- "This neighbor hasn't completed verification. Be cautious." — Satoshi Regular, 13px, `#E53E3E`
- Close button

#### 3. Message Bubbles
- Padding: 12px 20px
- Gap: 8px between messages

**Sent Bubble**:
- Background: `#2B5C7D`
- Text: White, Satoshi Regular, 15px
- Border radius: 18px (top-left, top-right, bottom-left), 4px bottom-right
- Max width: 75%
- Padding: 12px 16px
- Time: "10:30 AM" — Satoshi Regular, 11px, `rgba(255,255,255,0.70)`, below bubble right-aligned

**Received Bubble**:
- Background: `#FFFFFF`
- Border: 1px `#E2E8F0`
- Text: `#2D3748`, Satoshi Regular, 15px
- Border radius: 18px (top-left, top-right, bottom-right), 4px bottom-left
- Max width: 75%

**Listing Card in Chat**:
- Shared marketplace listing appears as rich card
- Image thumbnail, title, price, "View listing" button
- Tap opens Listing Detail

**Date Dividers**:
- Centered: "Today", "Yesterday" — Satoshi Regular, 12px, `#718096`, uppercase
- Horizontal lines on both sides: 1px `#E2E8F0`

#### 4. Typing Indicator
- Three dots animation in received bubble style
- Dots: `#718096`, sequential bounce

#### 5. Input Bar
- Background: `#FFFFFF`
- Border top: 1px `#E2E8F0`
- Height: 56px + safe area + keyboard
- Left: Plus icon (Phosphor), 24px, `#718096` → opens attachment sheet
- Center: Input field "Type a message...", Satoshi Regular, 16px
- Right: Send button (paper plane), 24px, `#2B5C7D`, disabled until text entered

---

## SCREEN 20 — Own Profile

**Purpose**: User's own profile view

### Layout Structure
- Background: `#F8F9FA`
- Hero section with blue background
- Scrollable content below

### Visual Elements

#### 1. Hero Section (240px height)
- Background: `#2B5C7D`
- Top: 
  - Back arrow (if navigated from elsewhere) or Settings gear icon, 24px, white
  - Share icon, 24px, white
- Center:
  - Avatar: 96px circle, white border 3px
  - If no photo: Initial letter ("H") in `#4A8BB5` circle, white text Clash Display Bold 40px
  - Camera icon overlay bottom-right: 32px circle, white bg, `#2B5C7D` camera icon (add photo)
- Below avatar:
  - "Harsh P." — Clash Display SemiBold, 22px, white
  - Location row: Map pin icon 14px + "Bopal, Ahmedabad" — Satoshi Regular, 14px, `rgba(255,255,255,0.80)`
  - Verified badge: "Verified Neighbor" — pill, `#38A169` bg, white text, Satoshi Bold 11px, checkmark icon

#### 2. Action Buttons (overlap hero bottom)
- Position: bottom of hero, extending 28px into white area
- Two buttons side by side, 20px horizontal padding, 12px gap:
  - "Edit Profile" — Primary CTA (smaller, 48px height)
  - "Add business page" — Ghost button (48px height)

#### 3. Dashboard Card
- Card styling, margin top 40px (to clear overlapping buttons)
- Padding: 20px
- Header: "Dashboard" — Satoshi SemiBold, 17px + "Only visible to you" — Satoshi Regular, 13px, `#718096`
- Profile Progress:
  - "Profile progress: 20%" — Satoshi SemiBold, 15px
  - Progress bar: 5 segments, 1 filled `#2B5C7D`, 4 empty `#E2E8F0`
  - Height: 6px, gap: 4px, radius: 3px
- Quick actions row (horizontal scroll):
  - "Add a profile photo" — Ghost chip
  - "Add a bio" — Ghost chip
  - "Post your introduction" — Ghost chip

#### 4. Stats Row
- 3 columns, evenly spaced
- Divider vertical lines 1px `#E2E8F0`
- "12" — Clash Display Bold, 20px, `#2D3748` / "Posts" — Satoshi Regular, 13px, `#718096`
- "5" / "Helpful"
- "3" / "Sold"

#### 5. Content Tabs
- Tab bar: "My Posts" | "My Listings"
- Active: text `#2D3748`, bottom border 2px `#2B5C7D`
- Content: Grid or list of user's posts/listings
- Empty state: "No posts yet" + "Create a post" button

#### 6. Menu Grid (below tabs or in separate section)
- 2-column grid:
  - Bookmarks (bookmark icon)
  - Events (calendar icon)
  - Interests (heart icon)
- Each: card styling, icon 24px `#2B5C7D`, label Satoshi SemiBold 15px

---

## SCREEN 21 — Settings

**Purpose**: App settings and account management

### Layout Structure
- Background: `#F8F9FA`
- Grouped list sections

### Visual Elements

#### 1. Top App Bar
- "Settings" — Clash Display SemiBold, 22px
- Left: Back arrow

#### 2. Settings Groups

**Group 1: Account**
- Card container (white, 18px radius, 1px border `#E2E8F0`)
- Items (56px height each, 20px horizontal padding):
  1. Account settings — User icon, "Account settings", chevron right
  2. Privacy settings — Lock icon, "Privacy settings", chevron right
  3. Notifications — Bell icon, "Notifications", chevron right
  4. Feed preferences — Sliders icon, "Feed preferences", chevron right
  5. Appearance — Moon icon, "Appearance · Light Mode", chevron right
  6. Add business page — Plus circle icon, "Add business page", chevron right
- Divider between items: 1px `#E2E8F0`

**Group 2: Support & Legal**
- Same card styling
- Items:
  1. Help Center — Question icon
  2. Privacy Policy — Document icon
  3. Member Agreement — FileText icon
  4. Share this app — Share icon
  5. Licenses — Certificate icon

**Group 3: Account Actions**
- "Log Out" — Text button, `#E53E3E`, Satoshi SemiBold, 16px, 56px height
- "Deactivate your account" — Text button, `#718096`, Satoshi Regular, 14px

**Group 4: App Info**
- "Version 5.13.2 (1251427)" — Satoshi Regular, 13px, `#718096`, centered

---

## SCREEN 22 — Safety Alert Detail

**Purpose**: High-priority safety alert full view

### Layout Structure
- Full screen, distinct from normal posts
- Red accent throughout
- Urgency indicators

### Visual Elements

#### 1. Top Bar
- Background: `#E53E3E` (Urgent Red)
- Left: Back arrow, white
- Center: "SAFETY ALERT" — Satoshi Bold, 14px, white, uppercase, letter-spacing 2px
- Right: Share icon, white

#### 2. Urgency Strip
- Background: `#FFF5F5`
- Padding: 12px 20px
- Left: Warning triangle icon, 24px, `#E53E3E`
- "URGENT — Posted 15 minutes ago" — Satoshi SemiBold, 15px, `#E53E3E`
- "Live" badge (if ongoing): pill, `#E53E3E` bg, white text

#### 3. Alert Content
- Padding: 20px
- Author: Avatar 40px + "C. L." + "Area Lead" badge (gold star)
- Title: "Power outage reported" — Clash Display SemiBold, 22px, `#2D3748`
- Body: Full alert text — Satoshi Regular, 16px, `#2D3748`, line-height 24px
- Map preview: 160px height, 14px radius, shows alert location pin

#### 4. Impact Stats
- Card: white, 14px radius
- "306 customers affected" — Satoshi SemiBold, 15px
- "Crews dispatched" — Satoshi Regular, 14px, `#38A169`
- "Est. restoration: 3-4 hours" — Satoshi Regular, 14px, `#718096`

#### 5. Action Buttons
- "I can confirm this" — Ghost button (helps verify)
- "Mark as resolved" — Primary CTA (only for OP or Area Lead)
- "Contact emergency" — Accent CTA (if phone provided)

#### 6. Comments
- Same as Post Detail but with red accent
- "Stay safe everyone!" type community responses

---

## SCREEN 23 — Marketplace

**Purpose**: Browse neighborhood listings

### Layout Structure
- Background: `#F8F9FA`
- Filter bar
- 2-column grid
- Bottom nav

### Visual Elements

#### 1. Top App Bar
- "Marketplace" — Clash Display SemiBold, 22px
- Right: Search icon + Filter icon (Phosphor "Faders")

#### 2. Filter Bar
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Padding: 12px 20px
- Horizontal scroll:
  - "My listings" — chip
  - "All categories" — dropdown chip with chevron
  - "Free" — toggle chip
  - "15 mi" — dropdown chip
- Gap: 8px

#### 3. Grid Layout
- Padding: 12px 20px
- 2 columns, gap 12px

**Listing Card**:
- Background: `#FFFFFF`
- Border radius: 18px
- Border: 1px `#E2E8F0`
- Image: aspect ratio 1:1, border radius top 18px
- Condition badge (top-left of image): "New" / "Used" — pill, `#E2E8F0` bg, `#718096` text
- "FREE" badge (if applicable): `#38A169` bg, white text, top-right
- "SOLD" overlay (if sold): full image, `rgba(0,0,0,0.60)` bg, "SOLD" white text Clash Display Bold 18px
- Content padding: 12px
  - Title: "Wooden Storage Chest..." — Satoshi SemiBold, 14px, `#2D3748`, 2 lines max
  - Price: "$5" — Satoshi Bold, 16px, `#38A169`
  - Distance: "· 8.6 mi" — Satoshi Regular, 13px, `#718096`

#### 4. Empty State
- "No listings near you" — Clash Display SemiBold, 22px
- "Be the first to sell something!" — Satoshi Regular, 15px
- "Create listing" — Primary CTA

---

## SCREEN 24 — Listing Detail

**Purpose**: Full product/service listing view

### Layout Structure
- Background: `#F8F9FA`
- Scrollable content
- Sticky CTA bar at bottom

### Visual Elements

#### 1. Image Carousel
- Height: 320px
- Full width
- Page dots: 6px circles
- Bookmark icon top-right: 40px circle, white bg, bookmark icon `#2D3748`
- Share icon top-right: same style
- Close/X top-left

#### 2. Listing Info
- Padding: 20px
- Title: "For Sale: Road bike" — Clash Display SemiBold, 22px
- Price: "£200" — Satoshi Bold, 24px, `#38A169`
- Condition badge: "Used — Like New" — pill, `#E2E8F0`
- Time: "10m ago" — Satoshi Regular, 13px, `#718096`

#### 3. Seller Card
- Card styling
- Padding: 16px
- Left: Avatar 48px
- Middle: "Justin Wu" — Satoshi SemiBold, 16px + "Dulwich Village" — Satoshi Regular, 13px
- Right: "View profile" — Satoshi SemiBold, 13px, `#2B5C7D`
- Below: "Seller's other listings" — horizontal scroll thumbnails

#### 4. Description
- "Lightly used 7-speed bike..." — Satoshi Regular, 15px, `#2D3748`

#### 5. Share Section
- "Share listing" — Satoshi SemiBold, 14px, `#718096`
- Horizontal row of share buttons:
  - Chat, Copy Link, Email, Facebook, More
  - Each: 48px circle, `#F8F9FA` bg, icon `#2D3748`
  - Label below: Satoshi Regular, 12px

#### 6. Sticky CTA Bar (bottom)
- Background: `#FFFFFF`
- Border top: 1px `#E2E8F0`
- Height: 72px + safe area
- Left: "Ask a question" — Ghost button (flex 1)
- Right: "Make offer" — Primary CTA (flex 1)
- Or if FREE: "Request item" — Accent CTA

---

## SCREEN 25 — Search

**Purpose**: Universal search across posts, neighbors, businesses

### Layout Structure
- Background: `#F8F9FA`
- Search bar fixed
- Tabbed results

### Visual Elements

#### 1. Search Bar (fixed)
- Background: `#FFFFFF`
- Border bottom: 1px `#E2E8F0`
- Padding: 12px 20px
- Search input with back arrow left
- Placeholder: "Search Nearhood..."
- Clear button when text entered
- Voice search icon right (microphone)

#### 2. Pre-search State (before typing)
- "Trending in Bopal" — Satoshi SemiBold, 14px, `#718096`
- Trending chips: "plumber", "water supply", "lost dog", "garage sale"
- Recent searches: "Recent" header + past search terms with clock icon

#### 3. Tabbed Results (after search)
- Tabs: "Posts", "Neighbors", "Businesses", "Listings"
- Active tab: `#2D3748`, bottom border 2px `#2B5C7D`
- Each tab shows count badge if results

**Posts Tab**:
- Vertical list of post cards (compact, 80px height)
- Left: Thumbnail 60px or category icon
- Title + preview + author

**Neighbors Tab**:
- List of user rows
- Avatar 40px, name, locality, mutual connections
- "Message" button right side

**Businesses Tab**:
- Business list cards
- Rating stars, distance, category

**Listings Tab**:
- Grid same as Marketplace

#### 4. Empty Search State
- "No results for 'xyz'" — Clash Display SemiBold, 20px
- "Try different keywords or check spelling" — Satoshi Regular, 14px

---

## SCREEN 26 — Business Directory

**Purpose**: Browse neighbor-recommended local businesses

### Layout Structure
- Background: `#F8F9FA`
- Search + filter
- Scrollable list

### Visual Elements

#### 1. Top App Bar
- "Local Businesses" — Clash Display SemiBold, 22px
- Right: Search icon + Map view toggle

#### 2. Search/Filter Bar
- Search: "Search businesses..."
- Category dropdown: "All categories" with chevron
- Sort: "Recommended" dropdown

#### 3. Business List
- Each row: 100px height, card styling, 20px horizontal padding
- Left: 
  - Business photo/logo: 64px square, 12px radius
  - Or placeholder: 64px square, `#F8F9FA` bg, store icon `#718096`
- Middle:
  - Name: "Sharma Plumbing Services" — Satoshi SemiBold, 16px
  - Category: "Plumber" — Satoshi Regular, 13px, `#718096`
  - Rating: Star icon `#D69E2E` + "4.8" — Satoshi SemiBold, 14px + "(24 reviews)" — Satoshi Regular, 13px
  - Distance: "0.8 mi" — Satoshi Regular, 13px, `#718096`
- Right:
  - "Recommended by neighbors" badge (if 30+ reviews): pill, `#D69E2E` bg, white text, 11px
  - Chevron right

#### 4. Featured Section (top)
- "Featured near you" — horizontal scroll
- Featured cards: 200px width, image top, info bottom
- "Featured" badge: `#2B5C7D` bg, white text

#### 5. Empty State
- "No businesses listed yet" — Clash Display SemiBold, 22px
- "Be the first to recommend a local business" — Satoshi Regular, 15px
- "Add a business" — Primary CTA

---

## SCREEN 27 — Business Detail

**Purpose**: Full business profile with reviews and actions

### Layout Structure
- Background: `#F8F9FA`
- Hero with image
- Info cards
- Reviews
- Sticky action bar

### Visual Elements

#### 1. Hero Image
- Height: 240px
- Full width
- Parallax scroll effect (image moves slower than scroll)
- Back arrow top-left: 40px circle, `rgba(0,0,0,0.40)` bg, white arrow
- Share + Bookmark top-right

#### 2. Business Info Card (overlaps hero bottom)
- Background: `#FFFFFF`
- Border radius: 24px top corners
- Padding: 24px 20px
- Transform: translateY(-20px)
- Name: "Sharma Plumbing Services" — Clash Display SemiBold, 24px
- Category + "·" + distance
- Rating row: 5 star icons (filled/empty `#D69E2E`/`#E2E8F0`) + "4.8" large + "24 reviews"
- "Recommended by neighbors" badge if applicable

#### 3. Action Buttons Row
- 3 buttons equally spaced:
  1. "Call" — Phone icon + label, `#2B5C7D`
  2. "WhatsApp" — WhatsApp icon + label, `#38A169`
  3. "Directions" — Navigation icon + label, `#3182CE`
- Each: 48px touch target, icon 24px, label Satoshi SemiBold 12px

#### 4. Info Section
- Card: white, 18px radius
- Hours table: Days + hours, current day highlighted `#EBF4FA`
- Address: full address with copy icon
- "Added by Rahul K." — Satoshi Regular, 13px, `#718096`

#### 5. Reviews Section
- Header: "Reviews (24)" + "Write a review" link `#2B5C7D`
- Review card:
  - Avatar 36px, name, time
  - Stars rating
  - Review text
  - "Helpful" button
- "See all reviews" — Ghost button

#### 6. Sticky Bottom Bar
- Background: `#FFFFFF`
- Border top: 1px `#E2E8F0`
- Height: 72px + safe area
- Left: "Save" — Ghost button with bookmark icon
- Right: "Contact" — Primary CTA

---

# PART D: SHARED COMPONENTS & PATTERNS

## Side Navigation Drawer
- Width: 80% of screen
- Background: `#FFFFFF`
- Shadow: `0 0 24px rgba(0,0,0,0.15)` on right edge
- Content:
  - User header: Avatar 64px, name, locality, verification badge
  - Menu items: Add business page, My profile, Local News, Events, Groups, Invite neighbors
  - Divider: 1px `#E2E8F0`
  - Bottom: Settings, Help Center
- Each item: 56px height, 20px padding, icon 24px `#718096`, label Satoshi SemiBold 15px
- Active item: `#EBF4FA` background, icon `#2B5C7D`

## Bottom Sheets
- Background: `#FFFFFF`
- Top radius: 24px
- Handle: 36px × 4px, `#E2E8F0`, centered top
- Backdrop: `rgba(0,0,0,0.40)`
- Enter: slide up 300ms ease-out
- Exit: slide down 200ms ease-in
- Drag to dismiss: threshold 100px velocity or 40% height

## Toast Notifications
- Position: top, below status bar
- Background: `#2D3748`
- Border radius: 12px
- Padding: 12px 16px
- Text: White, Satoshi SemiBold, 14px
- Icon left: 20px, category color
- Enter: slide down 300ms
- Exit: fade out 200ms, auto-dismiss 3s

## Loading States
- **Full screen**: Logo + WaveDots loader on `#F8F9FA`
- **Pull to refresh**: Native iOS/Android style, spinner `#2B5C7D`
- **Infinite scroll**: Bottom WaveDots loader, coral color
- **Skeleton**: Shimmer effect on cards, base `#F8F9FA`, highlight `#FFFFFF`

## Empty States (Generic Pattern)
- Illustration: 120px, line art style, `#E2E8F0`
- Title: Clash Display SemiBold, 22px, `#2D3748`
- Subtitle: Satoshi Regular, 15px, `#718096`
- CTA: Primary or Ghost button (if applicable)
- Centered vertically with 40% offset from top

## Error States
- Icon: Warning circle, 48px, `#E53E3E`
- Title: "Something went wrong" — Clash Display SemiBold, 20px
- Subtitle: Error description — Satoshi Regular, 14px, `#718096`
- "Try again" — Primary CTA

---

# PART E: ANIMATION & MOTION GUIDELINES

## Transition Durations
- Screen push: 300ms, ease-in-out
- Modal present: 350ms, spring ease
- Bottom sheet: 300ms, ease-out
- Tab switch: 200ms, cross-fade
- List item tap: 100ms, scale 0.98

## Micro-interactions
- Button press: scale 0.97, 80ms
- Icon tap: scale 0.9 → 1.0, 150ms
- Like animation: heart scales 1.0 → 1.3 → 1.0, 300ms, fills with `#E53E3E`
- New post appears: slide down + fade in, 400ms
- Notification badge: bounce in scale 0 → 1.2 → 1.0, 400ms
- Pull to refresh: rotate spinner, elastic snap back

## Scroll Behaviors
- Top app bar: elevates with shadow on scroll (0 → 4px shadow)
- Category chips: snap to nearest chip after scroll
- FAB: hides on scroll down, appears on scroll up (translateY 100px → 0, 300ms)
- Bottom nav: always fixed visible

---

# PART F: RESPONSIVE CONSIDERATIONS

## Tablet / Foldable
- Side drawer becomes permanent left sidebar (280px width)
- Feed max-width: 680px, centered
- Marketplace grid: 3 columns
- Explore map: 50% map, 50% list side-by-side

## Accessibility
- Minimum touch target: 44px × 44px
- Color contrast ratio: 4.5:1 minimum for text
- Dynamic type support: scales up to 200%
- VoiceOver/TalkBack labels on all interactive elements
- Reduce motion: disable non-essential animations
- High contrast mode: borders intensify to `#2D3748`

---

# APPENDIX: SCREEN CHECKLIST

| # | Screen Name | Status |
|---|-------------|--------|
| 01 | Splash | ✅ Defined |
| 02 | Login | ✅ Defined |
| 03 | Email Signup | ✅ Defined |
| 04 | Location Selection | ✅ Defined |
| 05 | Area Search | ✅ Defined |
| 06 | Address Details | ✅ Defined |
| 07 | Mobile Number | ✅ Defined |
| 08 | OTP Verification | ✅ Defined |
| 09 | Notification Permission | ✅ Defined |
| 10 | Community Rules | ✅ Defined |
| 11 | Home Feed | ✅ Defined |
| 12 | Post Detail | ✅ Defined |
| 13 | Category Picker | ✅ Defined |
| 14 | Compose Post | ✅ Defined |
| 15 | Explore (List) | ✅ Defined |
| 16 | Explore (Map) | ✅ Defined |
| 17 | Notifications | ✅ Defined |
| 18 | Inbox | ✅ Defined |
| 19 | Chat | ✅ Defined |
| 20 | Own Profile | ✅ Defined |
| 21 | Settings | ✅ Defined |
| 22 | Safety Alert Detail | ✅ Defined |
| 23 | Marketplace | ✅ Defined |
| 24 | Listing Detail | ✅ Defined |
| 25 | Search | ✅ Defined |
| 26 | Business Directory | ✅ Defined |
| 27 | Business Detail | ✅ Defined |

---

*Document Version: 1.0*
*Design System: Nearhood Light Mode*
*Total Screens Defined: 27*
*Date: 2026-05-27*
