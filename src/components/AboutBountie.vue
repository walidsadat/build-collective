<template>
  <div style="padding: 12px">
    <p>Bountie: {{ bountie.id }}</p>
    <p><b>Opened by: </b>{{ this.opener }}</p>
    <p><b>Linked to: </b>{{ bountie.link }}</p>
    <p><b>Amount of reward: </b>{{ bountie.reward }} ETH</p>
    <p>Status: {{ bountie.resolved ? 'Close' : 'Open' }}</p>
    <p v-if="bountie.resolved">Solved by: {{ solver }}</p>
    <a v-else href="#" @click="showBountie = !showBountie">
      Declare this bountie as fixed
    </a>
    <close-bountie
      :projectId="projectId"
      :bountieId="bountie.id"
      v-if="showBountie"
      @close="showBountie = false"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import CloseBountie from '@/components/CloseBountie.vue'

export default defineComponent({
  name: 'AboutBountie',
  components: { CloseBountie },
  props: { bountie: null, projectId: String },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const opener = ''
    const solver = ''
    const showBountie = false
    return { opener, solver, showBountie }
  },
  async mounted() {
    this.opener = (await this.contract.methods.user(this.bountie.opener).call()).username
    if (this.bountie.resolved)
      this.solver = (await this.contract.methods.user(this.bountie.solver).call()).username
  },
})
</script>