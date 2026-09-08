window.BLOG_REGISTRY = window.BLOG_REGISTRY || [];
window.BLOG_REGISTRY.push({
  "id": "2026-09-08-system-design-request-flow-database-and-load-balancer",
  "title": "System Design: Request Flow, Database and Load Balancer",
  "author": "Sukee Parker",
  "date": "2026-09-08",
  "category": "Technology",
  "tags": [],
  "excerpt": "The system design should start with comprehending the request flow, traffic patterns, and the source of data. Then, select a database, cache data and load balancers to scale the system and ensure fault tolerance.",
  "content": "<p>The system design should begin with understanding the <b>request flow</b>, which outlines the user’s journey through the system. Typically, the process starts when a user accesses a webpage or mobile app to make requests to our service, and the server delivers the requested service. These webpages and mobile apps serve as <b>traffic sources</b>. &nbsp;</p><p>After setting up the basic request flow, the next step is to scale the component in the system to handle increased traffic. This can be achieved by adding <b>caching</b> to web pages and using databases instead of simple file storage. For online transactions involving structured data that require strong consistency and transactional integrity, we would opt for a <b>relational database </b>like Oracle, SAP, MySQL, or PostgreSQL. However, for unstructured or semi-structured data requires super low latency and flexible formats, we would select a <b>noSQL database</b> like Cassandra, Redis, or MongoDB. For data in vector or graph format, , we would choose a vector database or a graph database like Neo4j. Lastly, for massive amounts of data that require columnar queries, we would use a <b>data warehouse</b> like Snowflake. For scaling, we have two options: vertical scaling and horizontal scaling. Vertical scaling involves adding more resources, such as compute or storage, to your existing server to increase its capacity. Horizontal scaling, on the other hand, involves adding more servers to your infrastructure to achieve the desired scaling. The<b> load balancer </b>is the service that directs traffic to multiple servers and handles<b> fault tolerance</b>. If one service is down, the load balancer can redirect traffic to its servers.&nbsp; To ensure reliability, we can add redundancy to avoid single points of failure (SPOF), which are components that, if they fail, can cause the entire system to fail.</p>",
  "contentType": "html",
  "autoRead": true,
  "pinned": false,
  "showHome": false,
  "parentId": "2026-06-15-system-design-fully-explained",
  "subpageSeq": 1
});
