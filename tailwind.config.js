module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: { textColor: ['visited'] },
  },
  plugins: [],
  purge: {
    content: ["./app/**/*.html.erb"],
  }
}
