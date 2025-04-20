export const reorderTracks = (tracks, trackIdAfter, trackToUpdate) => {
  let output = [];
  for (const i in tracks){
    if (tracks[i]?.id === trackIdAfter){
      output.push(trackToUpdate);
    }
    output.push(tracks[i]);
  }
  if (!trackIdAfter){
    output.push(trackToUpdate);
  }
  return (output);
}
