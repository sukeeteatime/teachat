window.BLOG_REGISTRY = window.BLOG_REGISTRY || [];
window.BLOG_REGISTRY.push({
  "id": "2026-06-15-system-design-fully-explained",
  "title": "System Design Fully Explained",
  "author": "Sukee Parker",
  "date": "2026-06-15",
  "category": "Technology",
  "tags": [],
  "excerpt": "The core principles of system design are about building systems that remain reliable, scalable, maintainable, and efficient as usage grows.",
  "content": "<p>System design involves constructing systems capable of delivering services while maintaining reliability, scalability, maintainability, and efficiency as usage increases. A helpful mental model is: Requirements → Estimate scale → Define APIs → Design data model → Design components → Identify bottlenecks → Implement scaling and reliability measures → Secure the system → Monitor its performance → Iterate on the design.&nbsp;<span>The key idea is that&nbsp;</span><strong>system design is mostly about trade-offs</strong><span>. There is rarely one perfect architecture. You are balancing&nbsp;</span><strong>cost, latency, availability, consistency, complexity, and scalability</strong><span>&nbsp;based on the actual business requirements.</span></p><div class=\"faq-block\"><div class=\"faq-block-label\">System Design Interview Questions&nbsp;</div><div class=\"faq-item\"><div class=\"faq-q\">Tell me what are left and right joins?</div><div class=\"faq-a\"><p>A LEFT JOIN retains all rows from the left table and matches rows from the right table whenever possible. If there’s no match, the right-side columns become NULL. On the other hand, a RIGHT JOIN performs the opposite operation: it retains all rows from the right table and matches rows from the left table whenever possible. For instance, consider the following query:</p><p>SELECT * FROM customers c</p><p>LEFT JOIN orders o</p><p>ON c.customer_id = o.customer_id;</p><p>This query returns every customer, including those who have never placed an order. In contrast, a RIGHT JOIN will return every order, even if some orders don’t have matching customer records.</p></div></div><div class=\"faq-item\"><div class=\"faq-q\">What are the typical algorithms used by load balancer?</div><div class=\"faq-a\"><p>The algorithms includes round robin, least connections, least response time, client IP Hash, weighted algorithm, geographic algorithm, and consistent hashing.</p></div></div><div class=\"faq-item\"><div class=\"faq-q\">What's the difference between HTTP Pooling and Websocket?</div><div class=\"faq-a\"><p>The core difference between HTTP Polling and WebSocket lies in how they establish communication: HTTP Polling is client-driven, requiring the client to repeatedly ask for updates, whereas WebSocket is server-driven, maintaining a single open connection where the server pushes updates instantly</p></div></div></div>",
  "contentType": "html",
  "autoRead": false,
  "pinned": false,
  "showHome": true
});
