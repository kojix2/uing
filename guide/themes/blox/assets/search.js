// Search widget functionality
document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search");
  const searchResults = document.getElementById("search_results");

  if (!searchInput) return;

  let documents = [];
  let miniSearch = null;

  // Initialize MiniSearch
  miniSearch = new MiniSearch({
    fields: ["title", "text"],
    searchOptions: {
      boost: { title: 2 },
      fuzzy: 0.2,
    },
  });

  // Load the search index exactly once; searches await this so a
  // quick Enter right after focus can't run against an empty index.
  let indexLoad = null;
  function ensureIndex() {
    if (!indexLoad) {
      indexLoad = (async function () {
        const response = await fetch("/search.json");
        documents = await response.json();
        miniSearch.addAll(documents);
      })().catch(function (error) {
        // allow retrying after a failed load
        indexLoad = null;
        console.error("Failed to load search index:", error);
      });
    }
    return indexLoad;
  }

  // Fetch search documents on focus
  searchInput.addEventListener("focus", function () {
    ensureIndex();
    searchInput.style.width = "15em";
  });

  // Start loading as soon as the user types, not just on focus
  searchInput.addEventListener("input", function () {
    ensureIndex();
  });

  // Hide results and shrink input on blur (with delay to allow link clicks)
  let blurTimeout;
  searchInput.addEventListener("blur", function () {
    blurTimeout = setTimeout(function () {
      searchInput.style.width = "2em";
      if (searchResults) {
        searchResults.style.display = "none";
      }
    }, 150);
  });

  // Cancel blur timeout if focusing back on search input
  searchInput.addEventListener("focus", function () {
    if (blurTimeout) {
      clearTimeout(blurTimeout);
    }
  });

  // Handle search on Enter key
  searchInput.addEventListener("keydown", function (event) {
    if (event.keyCode !== 13) return; // Only trigger on Enter key

    const query = searchInput.value.trim();
    if (query.length < 3) return; // Require at least 3 characters

    ensureIndex().then(function () {
      const results = miniSearch.search(query);

      if (searchResults) {
        searchResults.style.display = "block";

        if (results.length > 0) {
          // Create modal with results list
          let html = `<dialog open>
            <article class="search-modal">
              <header>
                <button aria-label="Close" rel="prev" onclick="this.closest('dialog').remove()"></button>
                <h3>Search Results for "${query}"</h3>
              </header>
              <ul class="search-results-list">`;
          results.forEach((result) => {
            const doc = documents.find((d) => d.id === result.id);
            if (doc) {
              html += `<li><a href="${doc.url}"><strong>${doc.title}</strong></a></li>`;
            }
          });
          html += `</ul>
            </article>
          </dialog>`;
          searchResults.innerHTML = html;
        } else {
          searchResults.innerHTML = `<dialog open>
            <article class="search-modal">
              <header>
                <button aria-label="Close" rel="prev" onclick="this.closest('dialog').remove()"></button>
                <h3>Search Results for "${query}"</h3>
              </header>
              <p>No results found</p>
            </article>
          </dialog>`;
        }
      }
    });
  });
});
