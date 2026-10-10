document.addEventListener("DOMContentLoaded", function () {
  const input = document.getElementById("search");
  const results = document.getElementById("search_results");
  const script = document.getElementById("search_script");
  if (!input || !results || !script) return;

  const japanese = window.location.pathname.includes("/guide_ja/");
  const labels = japanese
    ? { heading: "検索結果", empty: "見つかりませんでした", error: "検索索引を読み込めませんでした", close: "閉じる" }
    : { heading: "Search results", empty: "No results found", error: "Could not load the search index", close: "Close" };
  const indexUrl = new URL("search.json", script.src);
  let indexLoad;
  let timer;

  function normalize(value) {
    return String(value || "").normalize("NFKC").toLocaleLowerCase();
  }

  function loadIndex() {
    if (!indexLoad) {
      indexLoad = fetch(indexUrl)
        .then(function (response) {
          if (!response.ok) throw new Error(response.statusText);
          return response.json();
        })
        .then(function (documents) {
          return documents.map(function (document) {
            document.normalizedTitle = normalize(document.title);
            document.normalizedText = normalize(document.text);
            return document;
          });
        })
        .catch(function (error) {
          indexLoad = null;
          throw error;
        });
    }
    return indexLoad;
  }

  function findDocuments(documents, query) {
    const terms = normalize(query).split(/\s+/).filter(Boolean);
    const preferredGuide = japanese ? "/guide_ja/" : "/guide_en/";

    return documents
      .map(function (document) {
        let score = document.url.includes(preferredGuide) ? 20 : 0;
        for (const term of terms) {
          const titleMatch = document.normalizedTitle.includes(term);
          const textMatch = document.normalizedText.includes(term);
          if (!titleMatch && !textMatch) return null;
          if (titleMatch) score += 100;
          if (textMatch) score += 10;
        }
        return { document: document, score: score };
      })
      .filter(Boolean)
      .sort(function (a, b) {
        return b.score - a.score || a.document.title.localeCompare(b.document.title);
      })
      .slice(0, 20)
      .map(function (match) { return match.document; });
  }

  function snippet(document, query) {
    const normalizedText = document.normalizedText;
    const firstTerm = normalize(query).split(/\s+/).filter(Boolean)[0];
    const match = normalizedText.indexOf(firstTerm);
    const start = Math.max(0, match - 45);
    const text = document.text.slice(start, start + 140).trim();
    return (start > 0 ? "…" : "") + text + (start + 140 < document.text.length ? "…" : "");
  }

  function closeResults() {
    results.hidden = true;
    results.replaceChildren();
  }

  function makeModal(query) {
    const modal = document.createElement("section");
    modal.className = "search-modal";
    modal.setAttribute("role", "dialog");
    modal.setAttribute("aria-modal", "true");
    modal.setAttribute("aria-labelledby", "search_heading");

    const header = document.createElement("div");
    header.className = "search-modal-header";
    const heading = document.createElement("h2");
    heading.id = "search_heading";
    heading.textContent = labels.heading + ': "' + query + '"';
    const close = document.createElement("button");
    close.className = "search-close";
    close.type = "button";
    close.setAttribute("aria-label", labels.close);
    close.textContent = "×";
    close.addEventListener("click", closeResults);
    header.append(heading, close);
    modal.append(header);
    return modal;
  }

  function showMessage(query, message) {
    const modal = makeModal(query);
    const paragraph = document.createElement("p");
    paragraph.className = "search-message";
    paragraph.textContent = message;
    modal.append(paragraph);
    results.replaceChildren(modal);
    results.hidden = false;
  }

  function search() {
    const query = input.value.trim();
    if (normalize(query).length < 2) {
      closeResults();
      return;
    }

    loadIndex()
      .then(function (documents) {
        if (input.value.trim() !== query) return;
        const matches = findDocuments(documents, query);
        const modal = makeModal(query);
        if (matches.length === 0) {
          const paragraph = document.createElement("p");
          paragraph.className = "search-message";
          paragraph.textContent = labels.empty;
          modal.append(paragraph);
        } else {
          const list = document.createElement("ul");
          list.className = "search-results-list";
          for (const match of matches) {
            const item = document.createElement("li");
            const link = document.createElement("a");
            link.href = match.url;
            const title = document.createElement("span");
            title.className = "search-result-title";
            title.textContent = match.title;
            const summary = document.createElement("p");
            summary.className = "search-result-snippet";
            summary.textContent = snippet(match, query);
            link.append(title, summary);
            item.append(link);
            list.append(item);
          }
          modal.append(list);
        }
        results.replaceChildren(modal);
        results.hidden = false;
      })
      .catch(function () {
        if (input.value.trim() === query) showMessage(query, labels.error);
      });
  }

  input.addEventListener("focus", function () {
    loadIndex().catch(function () {});
  });
  input.addEventListener("input", function () {
    window.clearTimeout(timer);
    timer = window.setTimeout(search, 150);
  });
  input.addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      event.preventDefault();
      window.clearTimeout(timer);
      search();
    } else if (event.key === "Escape") {
      closeResults();
    }
  });
  results.addEventListener("click", function (event) {
    if (event.target === results) closeResults();
  });
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && !results.hidden) closeResults();
  });
});
