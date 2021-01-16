<template>
  <div>
    <div v-if="isPanelOpen" class="panel-backdrop" @click="closePanel" />

    <transition name="slide">
      <div v-if="isPanelOpen" class="panel-panel">
        <PickerSearchForm />
      </div>
    </transition>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex'
import PickerSearchForm from "@components/Picker/PickerSearchForm"

export default {
  name: 'ThePanel',
  components: { PickerSearchForm },
  computed: {
    ...mapState(['isPanelOpen']),
  },
  methods: {
    ...mapActions(['closePanel']),
  },
}
</script>

<style scoped>
.slide-enter-active, .slide-leave-active {
  transition: transform 0.2s ease;
}

.slide-enter, .slide-leave-to {
  transform: translateY(-100%);
  transition: all 150ms ease-in 0s
}

.panel-backdrop {
  background-color: rgba(19, 15, 64, .4);
  width: 100vw;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  cursor: pointer;

  z-index: 500;
}

.panel-panel {
  overflow-y: visible;
  background-color: #deedff;
  position: fixed;
  left: 0;
  top: 0;
  height: 20vh;
  padding: 2rem 50px 2rem 20px;
  width: 100vw;

  z-index: 999;
}
</style>
