<template lang="html">
          <div style="color:white">
            <p> &nbsp;&nbsp;&nbsp; You fixed this issue ?</p>
            <button style="color: red" @click="fixBountie">
              YES !
            </button>
               &nbsp;
            <button @click="this.$emit('close')">
              NO !
            </button>
          </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'CloseBountie',
  props: {
    projectId: String,
    bountieId: String,
  },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const balance = 0
    const amount = 0
    return { balance, amount }
  },
  methods: {
    async fixBountie() {
      const { projectId, bountieId, address } = this
      await this.contract.methods.closeBountie(projectId, bountieId, address).call()
      location.reload()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    this.balance = account.balance
  },
})
</script>