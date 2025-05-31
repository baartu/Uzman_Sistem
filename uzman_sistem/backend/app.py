from flask import Flask, request, jsonify
import mysql.connector
import pandas as pd
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/recommend', methods=['POST'])
def recommend():
    data = request.json
    print("Gelen veri:", data)

    
    conn = mysql.connector.connect(
        host='localhost',
        user='root',
        password='bartu',
        database='uzman_sistem'
    )

   
    df = pd.read_sql("SELECT * FROM pet_rules", conn)
    conn.close()

    
    weights = {
        'allergy': 9.76,
        'place_suitable': 9.15,
        'monthly_budget': 8.84,
        'daily_time': 7.93,
        'other_pet': 7.93,
        'home_time': 7.93,
        'baby': 7.63,
        'travel': 7.63,
        'age_range': 7.32
    }

    results = []
    
    for _, row in df.iterrows():
        score = 0.0
        explanation = []

        if data.get('allergy') and row['allergy'] == data['allergy']:
            score += weights['allergy']
            explanation.append("Alerji dostu")
        if data.get('place_suitable') and row['place_suitable'] == data['place_suitable']:
            score += weights['place_suitable']
            explanation.append("Küçük yaşam alanına uygun")
        if data.get('monthly_budget') and row['monthly_budget'] == data['monthly_budget']:
            score += weights['monthly_budget']
            explanation.append("Bütçeye uygun")
        if data.get('daily_time') and row['daily_time'] == data['daily_time']:
            score += weights['daily_time']
            explanation.append("Zaman ihtiyacına uygun")
        if data.get('other_pet') and row['other_pet'] == data['other_pet']:
            score += weights['other_pet']
            explanation.append("Diğer hayvanlarla uyumlu")
        if data.get('home_time') and row['home_time'] == data['home_time']:
            score += weights['home_time']
            explanation.append("Evde kalış süresine uygun")
        if data.get('baby') and row['baby'] == data['baby']:
            score += weights['baby']
            explanation.append("Bebekle uyumlu")
        if data.get('travel') and row['travel'] == data['travel']:
            score += weights['travel']
            explanation.append("Seyahat sıklığına uygun")
        if data.get('age_range') and row['age_range'] == data['age_range']:
            score += weights['age_range']
            explanation.append("Yaş aralığına uygun")

        results.append({
            'pet': row['pet'],
            'score': round(score, 2),
            'explanation': f"{row['pet']} seçilmesinin nedenleri: {', '.join(explanation)}."
        })

    
    final_results = sorted(results, key=lambda x: x['score'], reverse=True)[:3]
    print("Sonuçlar:", final_results)
    return jsonify(final_results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
