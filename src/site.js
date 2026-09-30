(function () {
  var reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // Always open at the top of the page
  if ("scrollRestoration" in history) history.scrollRestoration = "manual";

  // Mobile menu
  var menuBtn = document.getElementById("menu-btn");
  var links = document.getElementById("nav-links");
  function setMenu(open) {
    links.classList.toggle("open", open);
    menuBtn.setAttribute("aria-expanded", String(open));
    menuBtn.setAttribute("aria-label", open ? "Close menu" : "Open menu");
  }
  menuBtn.addEventListener("click", function () { setMenu(!links.classList.contains("open")); });
  links.addEventListener("click", function (e) { if (e.target.closest("a")) setMenu(false); });
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") setMenu(false); });

  // In-page links scroll without leaving a #hash behind
  document.addEventListener("click", function (e) {
    var a = e.target.closest('a[href^="#"]');
    if (!a) return;
    var id = a.getAttribute("href").slice(1);
    var el = id ? document.getElementById(id) : null;
    if (!el) return;
    e.preventDefault();
    el.scrollIntoView({ behavior: reduce ? "auto" : "smooth" });
  });

  // Hero photo stack: the top photo slides away and joins the back of the pile
  var stack = document.getElementById("stack");
  if (stack) {
    var cards = Array.prototype.slice.call(stack.querySelectorAll(".card"));
    var busy = false, timer = null, visible = true, hovering = false;
    function advance() {
      if (busy) return;
      busy = true;
      var top = cards[0];
      top.classList.add("leaving");
      setTimeout(function () {
        cards.push(cards.shift());
        top.classList.remove("leaving");
        cards.forEach(function (c, i) { c.setAttribute("data-pos", String(i)); });
        busy = false;
      }, 520);
    }
    function schedule() {
      clearInterval(timer);
      if (!reduce && visible && !hovering) timer = setInterval(advance, 3800);
    }
    stack.addEventListener("click", advance);
    stack.addEventListener("mouseenter", function () { hovering = true; schedule(); });
    stack.addEventListener("mouseleave", function () { hovering = false; schedule(); });
    if ("IntersectionObserver" in window) {
      new IntersectionObserver(function (entries) {
        visible = entries[0].isIntersecting; schedule();
      }).observe(stack);
    }
    document.addEventListener("visibilitychange", function () { visible = !document.hidden; schedule(); });
    schedule();
  }

  // Scroll reveal: only elements that start below the fold get hidden, so the page is complete at rest
  if (!reduce && "IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.remove("pre"); io.unobserve(en.target); }
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.12 });
    document.querySelectorAll(".reveal").forEach(function (el, i) {
      if (el.getBoundingClientRect().top > window.innerHeight) {
        el.classList.add("pre");
        el.style.transitionDelay = (i % 3) * 70 + "ms";
        io.observe(el);
      }
    });
  }

  // Count-up on the Rover numbers
  if (!reduce && "IntersectionObserver" in window) {
    var nums = document.querySelectorAll("[data-count]");
    var cio = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (!en.isIntersecting) return;
        cio.unobserve(en.target);
        var el = en.target, end = parseFloat(el.getAttribute("data-count"));
        var dec = parseInt(el.getAttribute("data-dec") || "0", 10), t0 = null;
        el.textContent = (0).toFixed(dec);
        function tick(t) {
          if (!t0) t0 = t;
          var p = Math.min(1, (t - t0) / 1100), v = end * (1 - Math.pow(1 - p, 3));
          el.textContent = v.toFixed(dec);
          if (p < 1) requestAnimationFrame(tick); else el.textContent = end.toFixed(dec);
        }
        requestAnimationFrame(tick);
      });
    }, { threshold: 0.6 });
    nums.forEach(function (n) { if (!n.firstElementChild) cio.observe(n); });
  }

  // Review rail buttons
  var track = document.getElementById("review-track");
  var prev = document.getElementById("rev-prev"), next = document.getElementById("rev-next");
  if (track && prev && next) {
    function step() {
      var card = track.querySelector(".review");
      return card ? card.getBoundingClientRect().width + 18 : 320;
    }
    function sync() {
      prev.disabled = track.scrollLeft < 8;
      next.disabled = track.scrollLeft + track.clientWidth >= track.scrollWidth - 8;
    }
    prev.addEventListener("click", function () { track.scrollBy({ left: -step(), behavior: reduce ? "auto" : "smooth" }); });
    next.addEventListener("click", function () { track.scrollBy({ left: step(), behavior: reduce ? "auto" : "smooth" }); });
    track.addEventListener("scroll", function () { window.requestAnimationFrame(sync); }, { passive: true });
    window.addEventListener("resize", sync);
    sync();
  }
})();
