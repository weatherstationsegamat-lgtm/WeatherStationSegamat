/* HEATCare Theme Switcher
   Change ONLY ACTIVE_THEME when a new campaign/event theme is needed.
   Add the matching header image inside this /themes folder.
*/
const HEATCARE_THEMES = {
  merdeka: {
    header: 'themes/merdeka-header.png',
    label: 'HEATcare Merdeka 69 header'
  },
  // Example for the next campaign:
  // hariMalaysia: {
  //   header: 'themes/hari-malaysia-header.png',
  //   label: 'HEATcare Hari Malaysia header'
  // }
};

const ACTIVE_THEME = 'merdeka';
const theme = HEATCARE_THEMES[ACTIVE_THEME] || HEATCARE_THEMES.merdeka;

document.documentElement.style.setProperty('--site-header-image', `url("${theme.header}")`);

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.approved-reference-header').forEach(el => {
    el.setAttribute('aria-label', theme.label);
  });
});
