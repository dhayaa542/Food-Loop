# Food Loop Backend

## Setup

1.  **Install Dependencies**:
    ```bash
    npm install
    ```

2.  **Database Setup**:
    - Ensure you have MySQL running on your machine.
    - If you are using Anaconda's MySQL and it fails to start, try installing MySQL via Homebrew:
        ```bash
        brew install mysql
        brew services start mysql
        ```
    - Create the database:
        ```bash
        node create_db.js
        ```

3.  **Run Server**:
    ```bash
    npm run dev
    ```
    The server will run on `http://localhost:5000`.

## API Endpoints

-   **Auth**: `/api/auth/register`, `/api/auth/login`
-   **Partners**: `/api/partners/profile`, `/api/partners/offers`, `/api/partners/orders`
-   **Offers**: `/api/offers` (Public)
-   **Orders**: `/api/orders` (Buyer)
