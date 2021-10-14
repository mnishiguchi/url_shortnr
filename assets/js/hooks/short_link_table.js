const ShortLinkTable = {
  // https://hexdocs.pm/phoenix_live_view/js-interop.html
  mounted() {
    this.handleEvent('short_link_deleted', ({ id }) => {
      this.el.querySelector(`#short_link-${id}`).remove();
    });

    // console.log('added to DOM', this.el);
  },
};

export default ShortLinkTable;
