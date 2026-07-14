document.addEventListener('DOMContentLoaded', () => {
  const categories = document.querySelectorAll('.category');

  categories.forEach(cat => {
    cat.addEventListener('click', () => {
      categories.forEach(c => c.classList.remove('active'));
      cat.classList.add('active');
    });
  });

  const searchBtn = document.querySelector('.search-btn');
  searchBtn.addEventListener('click', () => {
    const where = document.querySelector('.search-field input').value;
    if (where) {
      alert(`Searching safaris in "${where}"...`);
    } else {
      alert('Showing all available safaris!');
    }
  });

  const cards = document.querySelectorAll('.listing-card');
  cards.forEach(card => {
    card.addEventListener('click', () => {
      const title = card.querySelector('h3').textContent;
      const price = card.querySelector('.listing-price strong').textContent;
      alert(`Booking page for "${title}" coming soon!\nPrice: ${price} per person`);
    });
  });
});
