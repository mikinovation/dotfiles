<template>
  <div>
    <h1>Multiple Height Components</h1>
    <div v-for="item in items" :key="item.id" class="item" :style="{
      height: `${item.height}px`,
      backgroundColor: item.color
    }">
      <p>This is a test component with height: {{ item.height }}px</p>
    </div>
  </div>
</template>

<script lang="ts" setup>
type Item = {
  id: number;
  height: number;
  color: string;
};

const shuffleArray = (array: Item[]) => {
  const newArray = [...array];
  for (let i = newArray.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
  }
  return newArray;
};

const items: Item[] = shuffleArray([
  { id: 1, height: 100, color: "#FF5733" },
  { id: 2, height: 200, color: "#33FF57" },
  { id: 3, height: 300, color: "#3357FF" },
  { id: 4, height: 400, color: "#FF33A1" },
  { id: 5, height: 500, color: "#A133FF" },
  { id: 6, height: 600, color: "#33FFA1" },
  { id: 7, height: 700, color: "#FF5733" },
  { id: 8, height: 800, color: "#33FF57" },
  { id: 9, height: 900, color: "#3357FF" },
  { id: 10, height: 1000, color: "#FF33A1" },
  { id: 11, height: 2000, color: "#A1FF33" },
]);
</script>

<style scoped>
.item {
  page-break-inside: avoid;
  margin: 12px;
}
</style>
