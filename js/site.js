/* Rubrique Advisory Co.: small, dependency-free site script. */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---- Mobile navigation ---- */
  var toggle = document.querySelector(".nav-toggle");
  if (toggle) {
    toggle.addEventListener("click", function () {
      var open = document.body.classList.toggle("nav-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && document.body.classList.contains("nav-open")) {
        document.body.classList.remove("nav-open");
        toggle.setAttribute("aria-expanded", "false");
        toggle.focus();
      }
    });
  }

  /* ---- Hero word rotator ---- */
  var rotator = document.querySelector("[data-rotator]");
  if (rotator && !reduceMotion) {
    var words = rotator.querySelectorAll("span");
    var i = 0;
    if (words.length > 1) {
      setInterval(function () {
        words[i].classList.remove("is-active");
        i = (i + 1) % words.length;
        words[i].classList.add("is-active");
      }, 1900);
    }
  }

  /* ---- Footer year ---- */
  var year = document.querySelector("[data-year]");
  if (year) { year.textContent = new Date().getFullYear(); }

  /* ---- Contact form ---- */
  var form = document.querySelector("form[data-contact-form]");
  if (!form) { return; }

  // Pre-select a service when the page is opened as /contact/?interest=diagnostic etc.
  var params = new URLSearchParams(window.location.search);
  var interest = params.get("interest");
  if (interest) {
    var box = form.querySelector('input[name="services"][data-key="' + interest + '"]');
    if (box) { box.checked = true; }
  }

  var status = form.querySelector(".form__status");
  var button = form.querySelector('button[type="submit"]');

  function setStatus(msg, ok) {
    status.textContent = msg;
    status.className = "form__status " + (ok ? "is-ok" : "is-err");
  }

  form.addEventListener("submit", function (e) {
    var action = form.getAttribute("action") || "";
    if (action.indexOf("YOUR_FORM_ID") !== -1) {
      e.preventDefault();
      setStatus("This form is not connected yet. Please email hello@rubrique.co.", false);
      return;
    }
    if (!window.fetch || !window.FormData) { return; } // fall back to a normal POST

    e.preventDefault();
    button.disabled = true;
    var original = button.textContent;
    button.textContent = "Sending…";

    var data = new FormData(form);
    // Combine checked services into one readable line for the notification email.
    var picked = data.getAll("services");
    data.delete("services");
    data.append("services", picked.length ? picked.join("; ") : "(none selected)");

    fetch(action, { method: "POST", body: data, headers: { Accept: "application/json" } })
      .then(function (res) {
        if (res.ok) {
          form.reset();
          setStatus("Thank you. We received your note and will reply within 48 hours.", true);
        } else {
          return res.json().then(function (j) {
            var msg = (j && j.errors && j.errors.map(function (x) { return x.message; }).join(" ")) ||
              "Something went wrong. Please email hello@rubrique.co.";
            setStatus(msg, false);
          });
        }
      })
      .catch(function () {
        setStatus("Network error. Please try again or email hello@rubrique.co.", false);
      })
      .then(function () {
        button.disabled = false;
        button.textContent = original;
      });
  });
})();
