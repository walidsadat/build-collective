<template>
  <div style="padding: 12px">
    <h2>{{ project.name }}</h2>
    <p>
      <b>Owner: </b>
      {{ project.belongsToUser ? project.owner.username : project.owner.name }}
    </p>
    <div>
      <b>Contributors: </b>
      <p
        v-for="contributor in project.contributors"
        v-bind:key="contributor"
        style="padding-left: 10px"
      >
        {{ contributor }}
      </p>
    </div>
    <p><b>Balance: </b>{{ project.balance }} tokens</p>
    <a href="#" @click="fullRecap"> More ...</a>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'AboutProject',
  props: { project: null },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  methods: {
    fullRecap() {
      this.$router.push({
        name: 'FullRecap',
        query: {
          id: this.project.id,
          ownerAddress: this.project.ownerAddress,
        },
      })
    },
  },
})
</script>