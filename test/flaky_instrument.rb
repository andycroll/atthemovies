Capybara.default_max_wait_time = Float(ENV["CAP_WAIT"]) if ENV["CAP_WAIT"]

LOGGER_JS = <<~JS
  (() => {
    const t0 = performance.timeOrigin;
    const log = (msg) => {
      try {
        const l = JSON.parse(sessionStorage.getItem("__log") || "[]");
        l.push(`${(performance.timeOrigin + performance.now()).toFixed(0)} ${location.pathname} ${msg}`);
        sessionStorage.setItem("__log", JSON.stringify(l));
      } catch (e) {}
    };
    log(`new-document readyState=${document.readyState} vis=${document.visibilityState}`);
    let lastFrame = null;
    const tick = (ts) => {
      if (lastFrame === null) log(`first-rAF`);
      else if (ts - lastFrame > 100) log(`rAF-gap ${(ts - lastFrame).toFixed(0)}ms`);
      lastFrame = ts;
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
    try {
      new PerformanceObserver((list) => list.getEntries().forEach((e) => log(`paint ${e.name} at ${e.startTime.toFixed(0)}`))).observe({ type: "paint", buffered: true });
    } catch (e) {}
    for (const type of ["mousedown", "mouseup", "click", "keydown", "submit", "focusin", "input", "change"]) {
      addEventListener(type, (e) => {
        const t = e.target;
        log(`${type} ${t.tagName || t}${t.name ? "[" + t.name + "]" : ""}${t.value !== undefined && type !== "keydown" ? "=" + String(t.value).slice(0, 30) : ""} default=${e.defaultPrevented} trusted=${e.isTrusted}${e.clientY !== undefined ? " y=" + e.clientY : ""}`);
      }, true);
    }
    for (const type of ["DOMContentLoaded", "load", "pageshow", "pagehide", "visibilitychange", "beforeunload", "turbo:load", "turbo:visit", "turbo:submit-start", "turbo:submit-end", "turbo:before-render", "turbo:render", "turbo:before-fetch-request", "turbo:before-fetch-response", "turbo:fetch-request-error", "turbo:reload", "turbo:before-prefetch", "scroll"]) {
      addEventListener(type, (e) => {
        const d = e.detail || {};
        log(`${type} ${d.url || (d.fetchOptions && d.fetchOptions.method) || ""} ${d.reason || ""} vis=${document.visibilityState} sy=${scrollY}`);
      }, true);
      document.addEventListener(type, () => {}, true);
    }
  })();
JS

module InstrumentedSystemTest
  def before_setup
    super
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: LOGGER_JS)
    page.driver.browser.execute_cdp("Emulation.setCPUThrottlingRate", rate: Integer(ENV["CPU_RATE"])) if ENV["CPU_RATE"]
  rescue => e
    warn "instrument setup failed #{e}"
  end

  def before_teardown
    if !passed? || ENV["DUMP_ALWAYS"]
      begin
        warn "=== browser event log"
        warn JSON.parse(page.evaluate_script("sessionStorage.getItem('__log')") || "[]").join("\n")
      rescue => e
        warn "log dump failed #{e}"
      end
    end
    super
  end
end

ApplicationSystemTestCase.prepend(InstrumentedSystemTest)

module TimedActions
  %i[visit fill_in click_on select take_screenshot assert_text assert_selector assert_no_selector].each do |m|
    define_method(m) do |*args, **kw, &blk|
      warn "#{Process.clock_gettime(Process::CLOCK_REALTIME, :millisecond)} RUBY #{m} #{args.first.to_s[0, 60]}" if ENV["TRACE_STEPS"]
      super(*args, **kw, &blk)
    end
  end
end
ApplicationSystemTestCase.prepend(TimedActions)
