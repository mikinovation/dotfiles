use tokio::net::TcpListener;
use axum::{
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = create_router();

    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn root() -> &'static str {
    "Hello, World!"
}


fn create_router() -> Router {
    Router::new()
        .route("/", get(root))
        .route("/users", post(create_user))
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
    use tower::util::ServiceExt;
    use http_body_util::BodyExt;

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
