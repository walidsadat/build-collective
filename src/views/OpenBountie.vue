<template>
  <form @submit.prevent="openBountie">
    <card title="Create a bountie">
      <label class="input-username"> Link </label>
      <input type="text" class="input-username" v-model="link" placeholder="Link (to a Git)"/>
      <label class="input-username">Amount of reward</label>
      <input type="number" class="input-username" v-model="reward"/>
      <button type="submit" class="button-link"/>
    </card>
  </form>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  name: 'OpenBountie',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const id = this.$route.query.id
    const owner = this.$route.query.ownerAddress
    const link = ''
    const reward = 0
    return { id, owner, link, reward }
  },
  methods: {
    async openBountie() {
      const { contract, id, owner, link, reward } =
        this
      await contract.methods.openBountie(owner, id, link, reward).send()
      this.$router.push({
        name: 'FullRecap',
        query: {
          id: this.id,
          ownerAddress: this.owner,
        }
      })
    },
  },
})
</script>

<style lang="css" scoped>

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}
</style>