import pandas as pd

def normalize_datetime_hourly(
    df: pd.DataFrame,
    col: str,
    tz: str = "Europe/Paris",
    nonexistent: str = "shift_forward",
    ambiguous: str = "NaT",
    resolve_ambiguous: str = "first",
    drop_original: bool = False,
) -> pd.DataFrame:

    s = df[col].astype("string").str.strip()

    # Normalize formats
    s = s.str.replace(" ", "T", regex=False)                 # make ISO-ish
    s = s.str.replace(r"\.\d+", "", regex=True)              # drop .000
    # IMPORTANT: fix offsets like +0200 / -0530 (with optional space)
    s = s.str.replace(r"\s*([+-]\d{2})(\d{2})$", r"\1:\2", regex=True)
    # handle Z if present
    s = s.str.replace(r"Z$", "+00:00", regex=True)

    # Detect explicit tz/offset
    has_tz = s.str.contains(r"(?:[+-]\d{2}:\d{2})$", regex=True, na=False)

    aware_utc = pd.to_datetime(s.where(has_tz), errors="coerce", utc=True)

    naive = pd.to_datetime(s.where(~has_tz), errors="coerce")
    localized = naive.dt.tz_localize(tz, nonexistent=nonexistent, ambiguous=ambiguous)

    if ambiguous == "NaT":
        mask = localized.isna() & naive.notna()
        if mask.any():
            amb_flag = True if resolve_ambiguous == "first" else False
            localized_resolved = naive.dt.tz_localize(
                tz, nonexistent=nonexistent, ambiguous=amb_flag
            )
            localized = localized.where(~mask, localized_resolved)

    combined_utc = aware_utc.where(has_tz, localized.dt.tz_convert("UTC"))
    combined_utc = combined_utc.dt.floor("h")
    out_tz = combined_utc.dt.tz_convert(tz)

    df_out = df.copy()
    target_col = col if drop_original else f"{col}_dt"
    df_out[target_col] = out_tz
    return df_out
