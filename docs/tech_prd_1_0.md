### **Product Requirements Document: Gridlock X & O Evolved**

* **Document Status:** Draft
* **Version:** 1.0
* **Date:** October 10, 2025
* **Author:** Gemini AI
* **Stakeholders:** Product, Design, Engineering, Marketing

### **1. Introduction & Vision**

**1.1. Project Overview**
Gridlock: X & O Evolved is a mobile-first, free-to-play puzzle game that reimagines classic Tic-Tac-Toe for the modern, social media-driven era. By introducing dynamic rule modifiers, strategic depth, and built-in viral mechanics, Gridlock transforms a universally known game into an endlessly replayable, highly shareable, and competitive experience.

**1.2. Vision Statement**
To become the go-to "lunch break" game for a global audience by blending nostalgic simplicity with strategic, unpredictable gameplay that thrives on social platforms and fuels friendly competition.

**1.3. Business & Product Goals**
* **Goal 1: Achieve Virality:** Attain a virality coefficient (K-factor) greater than 1 within six months of launch, driven by organic social sharing.
* **Goal 2: Maximize Engagement:** Achieve a Day-7 retention rate of over 30% by creating a compelling and varied core loop.
* **Goal 3: Drive Revenue:** Establish a non-intrusive monetization model focused on cosmetics, aiming for a 5% payer conversion rate.
* **Goal 4: Become a Platform:** Build a scalable foundation for future modifiers, social features, and tournaments.

### **2. Target Audience**

* **2.1. Primary Audience: The Social Gamer (Ages 16-28)**
    * **Behavior:** Highly active on social media (TikTok, Instagram, Twitter). Enjoys quick, visually appealing mobile games they can play with friends. Motivated by trends, challenges, and shareable moments.
    * **Needs:** A game that is easy to learn but offers surprising depth. Seamless integration for sharing gameplay clips. A sense of community and competition.

* **2.2. Secondary Audience: The Casual Competitor (Ages 25-45)**
    * **Behavior:** Plays mobile games to de-stress or kill time (e.g., during commutes). Appreciates strategy but has low tolerance for steep learning curves. Motivated by personal progress, leaderboards, and puzzles.
    * **Needs:** Quick match times. A satisfying sense of skill progression. A fair and balanced matchmaking system.

### **3. Core Gameplay & Features**

**3.1. Core Game Loop**
1.  Player initiates a match via matchmaking.
2.  The system randomly selects a Game Mode and Modifier for the round.
3.  Players engage in a turn-based match according to the modifier's rules.
4.  A winner, loser, or draw is declared.
5.  Streaks and stats are updated. Players are presented with shareable moments.
6.  Players can rematch or find a new opponent.

**3.2. Game Setup System**
* **Requirement 3.2.1:** On match start, the system must first randomly select one of two categories: "The Hand You're Dealt" or "Forced Moves." The selection must be clearly animated for the players.
* **Requirement 3.2.2:** After category selection, the system must randomly select one modifier from the chosen category's pool. This selection must also be clearly animated, followed by a visual transformation of the grid to reflect the rules.
* **Requirement 3.2.3:** A 3-second, non-skippable countdown timer must occur after the modifier is revealed and before the first turn begins.

**3.3. Game Modifiers (Full rules and edge cases as defined previously)**

* **3.3.1. Category: "The Hand You're Dealt"**
    * **Modifier: Blocked Squares:** The system must generate two blocked squares in a configuration that still allows for at least one possible winning line.
    * **Modifier: Gravity Well:** The system must handle all physics and win-state checks post-slide, including draws and self-sabotage wins.
    * **Modifier: Volatile Squares:** The system must process the explosion and piece removal *before* checking for win/draw conditions.

* **3.3.2. Category: "Forced Moves"**
    * **Modifier: The Spinner:** The system must highlight two distinct, unoccupied squares if available. If only one is available, it must highlight that one.
    * **Modifier: Opponent's Choice (Ultimate Mode):** The system requires a 9-grid layout. It must correctly track valid moves, mini-grid wins/draws, and wildcard conditions. The game state must be checked for an unwinnable main board after each mini-grid is completed.

**3.4. Viral & Engagement Systems**

* **3.4.1. Streaks System**
    * **Win Streaks:** The backend must track consecutive wins per player. The UI must display this with a prominent visual counter (e.g., a flame icon 🔥) that intensifies at milestones (5, 10, 25, etc.). A special "Streak vs. Streak" match intro must be triggered when applicable.
    * **Daily Streaks:** The system must track consecutive days a player plays at least one match, providing escalating daily login rewards.

* **3.4.2. Shareable Moments**
    * The client must auto-generate a short video clip (5-10 seconds) for key moments:
        * Reaching a win streak milestone.
        * Winning in a spectacular fashion (e.g., a "Gravity Well" trick shot).
        * Losing a high-value streak (a "heartbreak" moment).
    * The share functionality must have a one-tap integration with TikTok, Instagram Reels, and other relevant platforms, pre-populating with relevant hashtags (e.g., `#GridlockEvolved`).

* **3.4.3. Leaderboards**
    * The backend must support global and friend-based leaderboards, filterable by:
        * Highest Win Streak (All-Time and Weekly)
        * Total Wins
        * Competitive Rank (future implementation)

**3.5. Monetization & Customization**

* **3.5.1. In-Game Store:** A store for purchasing cosmetic items using soft and hard currency.
* **3.5.2. Cosmetic Items:**
    * **Mark Skins:** Customizable designs for the 'X' and 'O' marks.
    * **Board Skins:** Themed backgrounds and grid designs.
    * **Win Animations:** Unique visual effects for a winning move.
* **3.5.3. Rewarded Ads:** Players can optionally watch a video ad to earn soft currency. This shall not be intrusive to the core gameplay loop.

### **4. Technical Requirements**

* **4.1. Platform:** Mobile-first (iOS and Android). Developed in a cross-platform engine like Unity or Godot.
* **4.2. Backend & Infrastructure:**
    * Scalable server architecture to handle real-time matchmaking, game state management, and leaderboards.
    * Robust database to store player profiles, stats, streak data, and purchased items.
    * Fair and reliable randomization logic for game mode selection is critical and must be server-authoritative to prevent exploits.
* **4.3. Social Integration:** Deep API integration with TikTok (Creative Kit) and Instagram for seamless video sharing. Standard social logins (Google, Apple, Facebook) for account management.
* **4.4. Analytics:**
    * Implement a robust analytics suite (e.g., Firebase, Amplitude) to track KPIs.
    * Key events to track: match completion rates per modifier, average match time, feature adoption (sharing, store visits), and player progression.

### **5. Success Metrics (KPIs)**

* **Virality:** K-factor, number of shares per user, installs from social channels.
* **Engagement:** DAU/MAU (Daily/Monthly Active Users), Session Length, Day-1/Day-7/Day-30 Retention Rates.
* **Monetization:** ARPDAU (Average Revenue Per Daily Active User), Conversion Rate (percentage of players who make a purchase), sales data for cosmetic categories.
* **Performance:** Crash-free rate > 99.5%, average matchmaking time < 10 seconds.

### **6. Future Scope (Post-Launch)**

* Ranked/Competitive Mode with a seasonal ELO system.
* Tournament Mode.
* Addition of new game modifiers on a quarterly basis to keep the meta fresh.
* Social features like Clans/Groups and in-game chat.
* 2v2 Team Modes.