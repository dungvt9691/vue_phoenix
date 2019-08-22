<template>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'ImageShow',
  beforeMount() {
    this.updateImagePreview(true);
  },
  methods: {
    ...mapActions(['updateImagePreview']),
  },
};
</script>
