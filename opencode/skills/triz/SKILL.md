---
name: triz
description: Use when facing engineering contradictions or tradeoffs that seem like zero-sum compromises. Resolves "improve X but Y degrades" by eliminating the contradiction via separation principles and 40 inventive principles. Works on technical, process, resource, and system design problems across any domain.
---

# TRIZ Framework (Theory of Inventive Problem Solving)

Use this framework when facing contradictions or tradeoffs that seem unresolvable. TRIZ eliminates contradictions rather than compromising on them.

Developed by Genrich Altshuller (1946, USSR) from analysis of ~40,000+ patents. Core insight: inventive solutions resolve contradictions, they don't trade off. The same 40 inventive principles recur across all fields of engineering.

## Core Concepts

### Technical Contradiction
Improving parameter A degrades parameter B. Example: "More security" vs "less convenience." The 40 inventive principles resolve these.

### Physical Contradiction
Object needs property X AND not-X simultaneously. Example: "Config must be reproducible" AND "config must be flexible." The separation principles resolve these.

### Ideal Final Result (IFR)
State the desired end as if the problem solved itself: "The system performs function X *by itself*, without introducing any new components, costs, or side effects." Most problems jump to "how do I optimize X" — IFR asks "what if X didn't need to exist?"

## Stages

### 1. IDENTIFY THE CONTRADICTION
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find how others have approached this contradiction. Do NOT rely on training data.**
- What parameter improves? What parameter degrades as a result?
- Is this a technical contradiction (A vs B tradeoff) or physical contradiction (X and not-X)?
- Can you state it as: "I need [A] but [not-A] because [reason]"?
- Search for how this contradiction manifests in other fields — same patterns recur
- Frame the Ideal Final Result: what would the ideal solution look like if it solved itself?

### 2. APPLY SEPARATION PRINCIPLES (for physical contradictions)
If the contradiction is physical (X and not-X), apply the four separation axes:

**Separation in space:** Contradictory properties exist in different locations.
- Example: Sandboxed browser in one namespace, file access through portal at controlled boundary — both exist, no compromise
- Example: Dedicated hobby room (messy allowed), living space (minimal) — both fully realized

**Separation in time:** Contradictory properties exist at different moments.
- Example: Strong auth once per session via SSH agent caching, not per operation. Security at login, convenience during use
- Example: Periodization — intense training blocks alternate with deload blocks. Both fully realized

**Separation between whole and parts:** Whole has one property, parts have another.
- Example: Lockfile pins dependencies (reproducible whole), config files freeform (flexible parts)
- Example: Standardized backend, customizable frontend. Whole is standard, parts are custom

**Separation by condition:** Property depends on a trigger or condition.
- Example: Verbose logging in dev condition, silent in production condition — same binary
- Example: Spending threshold — below X spend freely, above X requires deliberation. Friction appears only when it matters

### 3. APPLY 40 INVENTIVE PRINCIPLES (for technical contradictions)
If separation alone doesn't resolve it, or the contradiction is technical (A vs B), consult the 40 principles. The contradiction matrix (39x39) recommends which principles resolve which parameter conflicts. Search for the specific principle applications.

**The 40 Inventive Principles (Altshuller, from patent analysis):**

1. **Segmentation** — Divide an object into independent parts; make easy to disassemble; increase fragmentation.
   - Stick vacuum with detachable handheld unit; mainframe→PCs; modular furniture; Venetian blinds replacing solid shades; powdered welding metal for better penetration.

2. **Taking out** — Separate an interfering part or property; single out only the necessary part.
   - Vacuum bag extracting air; noisy compressor outside building; fiber optics separating hot light source from where light needed; barking dog sound without the dog.

3. **Local quality** — Change uniform→non-uniform; each part in optimal conditions; each part different function.
   - Football boots with longer heel studs, shorter front studs; lunch box compartments for hot/cold/liquid; pencil with eraser; hammer with nail puller; multi-function tool.

4. **Asymmetry** — Replace symmetrical with asymmetrical; increase degree of asymmetry.
   - Electrical plug with one wider prong (impossible to insert wrong way); asymmetrical mixing vessels; flat spot on cylindrical shaft; oval O-rings for better sealing; astigmatic optics to merge colors.

5. **Merging** — Bring together similar objects for parallel operations; make operations contiguous/parallel in time.
   - Multi-blade razor; PCs in network; parallel microprocessors; chips on both sides of circuit board; Venetian blind slats linked; mulching lawnmower.

6. **Universality** — One object performs multiple functions; eliminate need for other parts.
   - Swiss army knife; toothbrush handle contains toothpaste; car safety seat converts to stroller; mulching lawnmower; CCD with micro-lenses on surface.

7. **Nested doll (Matryoshka)** — Place one object inside another; make one part pass through cavity in another.
   - Stackable garden chairs; measuring cups/spoons; Russian dolls; portable audio system (mic in transmitter in amplifier case); extending antenna; zoom lens; retractable landing gear.

8. **Anti-weight** — Compensate weight by merging with lift-providing object; interact with environment (aerodynamic/hydrodynamic/buoyancy).
   - Rear spoiler pressing car down at speed; helium balloon supporting signs; aircraft wing creating lift; hydrofoils lifting ship out of water.

9. **Preliminary anti-action** — Replace harmful+useful action with anti-actions; pre-stress to oppose known undesirable stresses.
   - Vaccine (weakened virus before infection); buffer solution preventing pH extremes; pre-stressed rebar before pouring concrete; lead apron for X-rays; masking tape before painting.

10. **Preliminary action** — Perform required change before needed; pre-arrange objects for immediate action.
    - Pre-drilled holes in flat-pack furniture; pre-pasted wallpaper; sterilized surgical tray; Kanban arrangements in JIT factory; flexible manufacturing cell.

11. **Beforehand cushioning** — Prepare emergency means beforehand to compensate for low reliability.
    - Ceiling sprinkler triggering on fire; backup parachute; alternate air system for aircraft instruments; UPS taking over when mains fail; magnetic strip on film directing developer to compensate poor exposure.

12. **Equipotentiality** — Limit position changes; eliminate need to raise/lower objects in a potential field.
    - Mechanic's pit (go under car instead of lifting); spring-loaded parts delivery; Panama Canal locks; loading dock at warehouse level; spring-loaded plate dispenser keeping top plate at counter level.

13. **The other way round** — Invert the action; make movable parts fixed and fixed parts movable; turn upside down.
    - Cool inner part to loosen stuck parts instead of heating outer; MRI scanner (patient still, machine rotates); rotate part instead of tool; turn assembly upside down to insert screws; empty grain by inverting containers.

14. **Spheroidality / Curvature** — Replace linear with curved, flat with spherical, cube with ball; use rollers/balls/spirals; linear→rotary motion; use centrifugal force.
    - Curved monitor wrapping field of vision; arches and domes for strength; ball-point pen; mouse/trackball for cursor; washing machine spinning instead of wringing; spherical casters instead of cylindrical wheels.

15. **Dynamics** — Allow characteristics to change for optimal performance; divide into movable parts; rigid→movable/adaptive.
    - Flexible vacuum cleaner hose; butterfly keyboard; flexible boroscope for engines; flexible sigmoidoscope for medical examination.

16. **Partial or excessive actions** — If 100% is hard, use slightly less or slightly more of same method.
    - Apply silicone sealant in excess then smooth off; fill gas tank then top off; laser-cut oversized then machine down; 3D print support structures removed after; partially tighten all screws first to align, then fully tighten.

17. **Another dimension** — Move from 1D to 2D to 3D; use multi-story arrangement; tilt/re-orient; use another side.
    - Foldable smartphone doubling screen area; QR code (1D→2D barcode); five-axis cutting tool; 6-CD cassette; chips on both sides of PCB; vertical farming stacking trays; dump truck tilting.

18. **Mechanical vibration** — Cause oscillation/vibration; increase frequency (even ultrasonic); use resonant frequency; use piezoelectric; combine ultrasonic with EM fields.
    - Vibrating massage roller; electric carving knife; distribute powder with vibration; destroy gallstones with ultrasonic resonance; quartz crystal clock; induction furnace mixing alloys.

19. **Periodic action** — Replace continuous with periodic/pulsating; change frequency/magnitude; use pauses for different action.
    - Flashing bicycle light more visible than continuous; pulsed siren; FM vs Morse code; CPR: breathe after every 5 chest compressions.

20. **Continuity of useful action** — Carry on work continuously; all parts at full load; eliminate idle/intermittent actions.
    - Escalator running continuously; flywheel storing energy when vehicle stops; run bottleneck operations continuously; print during printer carriage return.

21. **Skipping** — Conduct harmful/hazardous operations at very high speed.
    - Femtosecond laser eye surgery (cutting too fast for tissue to heat); high-speed dentist drill avoiding heating; cut plastic faster than heat propagates; egg vitrification (ultra-rapid freezing prevents ice crystals).

22. **Blessing in disguise / Turn lemons into lemonade** — Use harmful factors for positive effect; combine harmful factors to cancel; amplify harm until it ceases to be harmful.
    - Regenerative braking converting kinetic energy to electricity; waste heat to generate power; recycle scrap as raw material; helium-oxygen mix eliminating both nitrogen narcosis and oxygen poisoning; backfire to eliminate forest fire fuel.

23. **Feedback** — Introduce feedback to improve process; if feedback exists, change its magnitude/influence.
    - Fitness watch alerting on heart rate zone; automatic volume control; gyrocompass autopilot; statistical process control; change autopilot sensitivity near airport; change thermostat sensitivity for cooling vs heating; AI code tool self-auditing errors.

24. **Intermediary** — Use intermediary carrier article or process; temporarily merge with easily-removed object.
    - Smartphone case absorbing shock instead of phone; carpenter's nailset between hammer and nail; pot holder to carry hot dishes.

25. **Self-service** — Object serves itself by performing auxiliary functions; use waste resources/energy/substances.
    - Robot vacuum returning to base to recharge; soda fountain pump powered by its own CO2 pressure; halogen lamp regenerating filament; co-generation (heat from process→electricity); compost from food/lawn waste; grey water reused for toilet flushing.

26. **Copying** — Use inexpensive copies instead of unavailable/expensive/fragile originals; replace with optical copies; move to IR/UV.
    - Crash-test dummy reproducing human body; VR instead of expensive vacation; audio tape instead of attending seminar; surveying from space photographs; sonograms for fetal health; infrared imaging detecting heat sources.

27. **Cheap short-living objects** — Replace expensive object with multiple inexpensive objects compromising some properties (e.g. longevity).
    - Disposable razor; surgical mask worn once; bin bag discarded with waste; single-use coffee capsule.

28. **Mechanics substitution** — Replace mechanical with sensory (optical/acoustic/taste/smell); use electric/magnetic/EM fields; static→movable fields; use fields with ferromagnetic particles.
    - Smartphone proximity door lock instead of mechanical key; acoustic fence for dog; bad-smelling compound in natural gas for leak detection; electrostatic powder mixing; 5G beamforming; induction heating with Curie point cutoff.

29. **Pneumatics and hydraulics** — Use gas/liquid parts instead of solid (inflatable, liquid-filled, air cushion, hydrostatic, hydro-reactive).
    - SUV air suspension (low on highway, high on trails); gel shoe inserts; hydraulic energy storage from deceleration.

30. **Flexible shells and thin films** — Use flexible shells/thin films instead of 3D structures; isolate object from external environment.
    - Hydrogel screen protector self-healing from scratches; inflatable winter covers for tennis courts; bipolar film floated on reservoir to limit evaporation.

31. **Porous materials** — Make object porous or add porous elements; if already porous, use pores to introduce useful substance/function.
    - Porous insole for ventilation/shock absorption/moisture wicking; drill holes to reduce weight; porous metal mesh wicking excess solder; hydrogen stored in palladium sponge pores (safer than gas).

32. **Color changes** — Change color of object/environment; change transparency; use color additives to observe hard-to-see processes; use luminescent/marked substances.
    - Forehead thermometer with liquid crystals; safe lights in darkroom; photolithography changing transparency; dye in water to locate leaks; smoke in wind tunnel; fluorescent dye detecting metal cracks; radioactive iodine for thyroid diagnostics.

33. **Homogeneity** — Make interacting objects of same material or material with identical properties.
    - Biodegradable peat pots planted directly with plant; container made of same material as contents (reduce reactions); diamond cutting tool made of diamonds; bone graft using patient's own bone (reduces rejection).

34. **Discarding and recovering** — Make portions that fulfilled function go away (dissolve/evaporate); restore consumable parts during operation.
    - Dissolving medicine capsule; dissolving surgical stitches absorbed by body; ice template for rammed earth structure (melts after); self-sharpening lawn mower blades; engine self-tune-up while running.

35. **Parameter changes** — Change physical state (gas/liquid/solid); change concentration/consistency; change flexibility; change temperature.
    - Freeze liquid candy centers then dip in chocolate; transport petroleum as liquid not gas; LPG stored as liquid; adjustable dampers reducing noise; vulcanize rubber; raise temperature above Curie point; cook food; freeze medical specimens.

36. **Phase transitions** — Use phenomena occurring during phase transitions (volume changes, heat absorption/release).
    - Cooling vest with phase-change material melting at 18°C absorbing body heat; water expanding when frozen (Hannibal splitting rocks in Alps); heat pumps using vaporization/condensation cycle.

37. **Thermal expansion** — Use thermal expansion/contraction of materials; use multiple materials with different coefficients.
    - Shrink wrap holding bottles together; shrink-fit bearing by heating outer ring then cooling; cool inner part to contract, heat outer to expand, assemble, return to equilibrium.

38. **Strong oxidants** — Replace common air with oxygen-enriched air; pure oxygen; ionized oxygen; ozone.
    - Hydrogen peroxide on wound; oxy-acetylene torch cutting at higher temperature; ionization to sterilize clean rooms; ionized air trapping pollutants in air cleaner; ozone to speed up chemical reactions.

39. **Inert atmosphere** — Replace normal environment with inert one; add neutral parts or inert additives.
    - Nitrogen in chip bags preventing fat oxidation and cushioning; argon atmosphere preventing hot filament degradation; inert ingredients in detergent making it easier to measure with conventional tools.

40. **Composite materials** — Change from uniform to composite (multiple) materials.
    - Bicycle tyre cross-section (rubber tread, recycled-rubber puncture layer, textile carcass, steel beads); carbon fiber/epoxy golf club shafts lighter and stronger; fiberglass surfboards; reinforced concrete (steel handles tension, concrete handles compression).

### 4. VERIFY: ELIMINATED OR COMPROMISED?
Check the proposed solution honestly:
- Does the solution let BOTH requirements be fully satisfied? Or did you slide back into compromise?
- If compromised: loop back. Try different separation axis, different principles, or reformulate the contradiction at a deeper level.
- The test: "Can both sides get 100% of what they need?" If no, you haven't resolved the contradiction yet.

### 5. GENERALIZE AND DOCUMENT
- Which principle(s) resolved it?
- Can this pattern apply to adjacent problems?
- Document the contradiction → principle → solution mapping for future reference

## Scope and Limitations

**TRIZ works on:** System/process design, resource allocation, architecture (any domain), engineering tradeoffs, structural contradictions.

**TRIZ does NOT work on:** Values-based decisions ("family vs career" — values tension, not technical contradiction), interpersonal/emotional problems ("honesty vs kindness" — relational, not structural), pure information problems ("is this claim true?" — no contradiction to eliminate), creative/artistic tensions (tension to maintain, not resolve).

If the problem is a values tension, redirect to `wrap` or `decision-record`. If it's an information problem, redirect to `scientific-method` or `research-ppdac`.

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At IDENTIFY THE CONTRADICTION, use `ai_venice_web_search` to find how this contradiction pattern appears in other fields. At APPLY 40 INVENTIVE PRINCIPLES, search for specific principle applications if the mapping isn't clear. The 40 principles and separation principles can be applied in combination — try multiple before concluding.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the IDENTIFY and APPLY PRINCIPLES stages. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
7. Web research fallback chain (use in this strict order):
   (a) `ai_venice_web_search` — primary.
   (b) `webfetch` — if Venice returns rate-limit errors, fetch known URLs directly.
   (c) Playwright browser tools — if both above fail AND router grants exclusive browser access in your Task prompt. Playwright is single-threaded (one browser instance shared across all agents), so only use it when explicitly granted.
   All three methods require sequential execution — never run parallel agents doing web research.
   Treat Playwright results same as search results — cite URLs, never fabricate.
   Playwright is for WEB BROWSING ONLY — do NOT use `playwright_browser_run_code` or `playwright_browser_evaluate` to write files, run shell commands, or execute code. If asked to write a file, return the full content in your response instead.
