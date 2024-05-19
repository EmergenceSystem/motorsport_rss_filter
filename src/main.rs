use rss_filter;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    rss_filter::start().await
}

