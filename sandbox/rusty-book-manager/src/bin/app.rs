use std::net::{Ipv4Addr, SocketAddr};

use anyhow::{Error, Result};
use axum::Router;
use api::route::health::build_health_check_routers;
use adapter::database::connect_database_with;
use registry::AppRegistry;
use tokio::net::TcpListener;
use shared::config::AppConfig;

#[tokio::main]
async fn main() -> Result<()> {
    bootstrap().await
}

async fn bootstrap() -> Result<()> {
    let app_config = AppConfig::new()?;
    let pool = connect_database_with(app_config.database);

    let registry = AppRegistry::new(pool);
    let app = Router::new()
        .merge(build_health_check_routers())
        .with_state(registry);
    let addr = SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 8080);
    let listener = TcpListener::bind(addr).await?;
    
    println!("Listening on {}", addr);

    axum::serve(listener, app).await.map_err(Error::from)
}
