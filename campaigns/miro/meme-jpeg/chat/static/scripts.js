(() => {
	const mv = document.querySelector("#media-viewer");

	// media viewer open
	document.querySelectorAll("img").forEach(img => img.addEventListener("click", (ev) => {
		ev.preventDefault();
		ev.stopPropagation();
		const targ = ev.target;

		const newImg = document.createElement("img");
		newImg.src = targ.src;
		newImg.alt = targ.alt;
		mv.appendChild(newImg);
		mv.classList.remove("hidden");
	}));

	// media viewer clickaway
	document.addEventListener("click", (ev) => {
		if (mv.classList.contains("hidden")) return;

		mv.classList.add("hidden");
		mv.replaceChildren();
	});
})();
