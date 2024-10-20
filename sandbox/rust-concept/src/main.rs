use tokio::net::TcpListener;
use axum::{
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() {
    init_tracing();

    let app = create_app().await;
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();

    tracing::debug!("Listening on: {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

fn init_tracing() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
            .unwrap_or_else(|_| format!("{}=debug", env!("CARGO_CRATE_NAME")).into())
        )
        .with(tracing_subscriber::fmt::layer())
        .init();
}

async fn root() -> &'static str {
    "Hello, World!"
}


async fn create_app() -> Router {
    let db_connection_str = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:password@localhost".to_string());

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_connection_str)
        .await
        .expect("Failed to create connection pool");

    Router::new()
        .route("/", get(root))
        .route("/users", post(create_user))
        .with_state(pool)
}

async fn create_user(
    Json(payload): Json<CreateUser>,
) -> (StatusCode, Json<User>) {
    let user = User {
        id: 1337,
        username: payload.username,
    };

    (StatusCode::CREATED, Json(user))
}

#[derive(Deserialize)]
struct CreateUser {
    username: String,
}

#[derive(Serialize)]
struct User {
    id: u64,
    username: String,
}

#[cfg(test)]
mod test {
    use super::*;
    use axum::{body::Body, http::Request};

    #[tokio::test]
    async fn test_root() {
        let app = create_router();
        let request = Request::get("/")
            .body(Body::empty())
            .unwrap();
        let response = app
            .oneshot(request)
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        assert_eq!(body, "Hello, World!");
    }
}
