### **Technical Task Breakdown: Gridlock X & O Evolved**

This breakdown translates the PRD into actionable tasks for sprint planning.

#### **Sprint Planning / Prioritization Focus:**
* **MVP Goal:** The initial focus should be on building a playable, end-to-end game loop. This means prioritizing **Epic 1, Epic 2 (with 2 simple modifiers), Epic 4 (basic account & matchmaking), and Epic 5 (core UI)**.
* **Post-MVP:** Once the core loop is stable, focus shifts to virality and retention (**Epic 3, Epic 6**) and then monetization (**Epic 7**).

---

### **Epic 1: Core Gameplay Loop**
*Goal: Implement the fundamental ability for two players to start, play, and finish a standard game.*

* **User Story 1.1:** As a player, I want to be matched with an opponent quickly so that I can start playing a game.
    * **Backend:** Create a matchmaking queue service.
    * **Backend:** Develop API endpoints for players to join/leave the queue.
    * **Client:** Implement UI for a "Play" button that calls the matchmaking API.
    * **Client:** Handle matchmaking states (Searching, Opponent Found, Connecting...).

* **User Story 1.2:** As a player, I want to play a turn-based game on a 3x3 grid so that I can compete against my opponent.
    * **Backend:** Create a real-time match management service (e.g., using WebSockets).
    * **Backend:** Develop server-authoritative logic for turn validation (is it the player's turn? is the square open?).
    * **Database:** Design a schema for `Matches` to store game state, players, and moves.
    * **Client:** Create a visual grid that can receive and display game state updates from the server.
    * **Client:** Implement input handling for a player to select a square and send the move to the server.

* **User Story 1.3:** As a player, I want the game to automatically detect and declare a win, loss, or draw so that the round ends fairly.
    * **Backend:** Implement win/loss/draw detection logic that runs after every valid move.
    * **Backend:** Broadcast the end-of-game state to both players.
    * **Client:** Display a clear end-of-game screen (e.g., "You Win!", "Draw").
    * **UI/UX:** Design victory, defeat, and draw animations/visuals.

---

### **Epic 2: Game Modifier System**
*Goal: Build the framework for dynamic modifiers and implement the initial set.*

* **User Story 2.1:** As a player, I want the game to randomly select a game mode before each round so that every match feels unique.
    * **Backend:** Develop a "Pre-Round Service" that randomly selects a Category and Modifier. This choice must be stored in the `Matches` record.
    * **Backend:** The matchmaking response must include the selected modifier for the upcoming game.
    * **Client:** Create the UI animation sequence for revealing the category and modifier.

* **User Story 2.2:** As a player, I want to play with the "Blocked Squares" and "The Spinner" modifiers.
    * **Task (Blocked Squares - Backend):** Enhance the Pre-Round Service to generate a valid pattern of 2 blocked squares and include their coordinates in the match data.
    * **Task (Blocked Squares - Client):** The client must be able to render the blocked squares and prevent player input on them.
    * **Task (The Spinner - Backend):** The turn validation logic must be updated to check if a player's move is one of the server-designated "spinner" choices for that turn.
    * **Task (The Spinner - Client):** Implement the spinner animation and highlight the playable squares for the current player's turn.

* **User Story 2.3:** As a player, I want to play with the "Gravity Well" and "Ultimate Mode" modifiers.
    * **Task (Gravity Well - Backend):** Implement post-move physics logic. The server must calculate the final position of the piece and re-run win checks.
    * **Task (Gravity Well - Client):** Create the animation for a piece sliding into the well.
    * **Task (Ultimate Mode - Backend):** This is a major task. A new game logic module is needed to manage 9 mini-grids, track mini-grid wins/draws, and handle the "wildcard" rule.
    * **Task (Ultimate Mode - Client):** Develop a new, more complex UI to render the 9x9 grid, highlight the active mini-grid, and display the main board's win state.

---

### **Epic 3: Viral & Social Systems**
*Goal: Integrate features designed to drive organic growth and social sharing.*

* **User Story 3.1:** As a player, I want to see my win streak increase so I can feel a sense of achievement and brag to my friends.
    * **Database:** Add `currentWinStreak` and `maxWinStreak` fields to the `Players` table.
    * **Backend:** Create logic to update player streaks after each match result.
    * **Client:** Display the streak counter prominently on the profile and in-game UI.
    * **UI/UX:** Design the "flame" icon and its intensity variations.

* **User Story 3.2:** As a player, I want to easily share a cool moment from my game to TikTok or Instagram.
    * **Client:** Implement a screen recording feature that captures the last 10 seconds of gameplay.
    * **Client:** On the end-of-game screen, add "Share" buttons that trigger the recording to be saved/cached.
    * **Client:** Integrate the native social sharing APIs for iOS (UIActivityViewController) and Android (ACTION_SEND Intent).
    * **Client:** Integrate the TikTok Creative Kit API for more seamless sharing.

---

### **Epic 4: Backend & Infrastructure**
*Goal: Build the foundational server-side services and database architecture.*

* **User Story 4.1:** As a user, I want to create an account so that my progress and purchases are saved.
    * **Task:** Set up a cloud database (e.g., Firestore, PostgreSQL).
    * **Task:** Design the `Players` schema (PlayerID, AuthDetails, Stats, Currency, Inventory).
    * **Task:** Implement an authentication service supporting social logins (Google, Apple).
    * **Task:** Create API endpoints for player login, registration, and profile fetching.

* **User Story 4.2:** As a developer, I need analytics to understand player behavior.
    * **Task:** Integrate a third-party analytics SDK (e.g., Firebase, Amplitude) into the client.
    * **Task:** Define and implement tracking for key events: `match_start`, `match_end`, `modifier_played`, `share_button_click`, `store_visit`.

---

### **Epic 5: UI/UX & Frontend Shell**
*Goal: Design and build the user interface and overall application structure.*

* **User Story 5.1:** As a user, I want a clean and intuitive interface to navigate between the main menu, matchmaking, and my profile.
    * **UI/UX:** Create wireframes and high-fidelity mockups for all primary screens.
    * **Client:** Build the main application shell with navigation (e.g., tab bar).
    * **Client:** Implement the screens for Home, Profile, Leaderboards, and Store.
    * **Art:** Create a consistent visual identity, including logos, fonts, and color palettes.

---

### **Epic 6: Player Progression & Meta Systems**
*Goal: Implement systems that drive long-term retention beyond the core game.*

* **User Story 6.1:** As a player, I want to check my ranking on a leaderboard to see how I stack up against others.
    * **Backend:** Use a sorted set data structure (e.g., Redis) to manage leaderboards for efficient ranking.
    * **Backend:** Create API endpoints to fetch leaderboard data (Global, Friends, Weekly).
    * **Client:** Build the UI to display leaderboard rankings.

* **User Story 6.2:** As a player, I want to receive daily rewards for logging in to encourage me to come back.
    * **Backend:** Implement logic to track daily logins and grant rewards.
    * **Client:** Create a UI popup to claim daily rewards.

---

### **Epic 7: Monetization & Store**
*Goal: Implement the in-app store and cosmetic customization features.*

* **User Story 7.1:** As a player, I want to buy cool skins for my X's and O's.
    * **Art:** Design a variety of cosmetic items (Mark skins, Board skins).
    * **Database:** Create `Items` and `PlayerInventory` tables.
    * **Backend:** Develop a store service with API endpoints to fetch item listings and process purchases.
    * **Client:** Build the store UI, including item previews and a purchase flow.
    * **Client:** Integrate the native IAP SDKs for iOS (StoreKit) and Android (Google Play Billing).

* **User Story 7.2:** As a player, I want to equip the cosmetics I own.
    * **Client:** Develop a "Locker" or "Customization" screen where players can select their equipped items.
    * **Client:** The game client must load the appropriate cosmetic assets based on the player's selection for each match.